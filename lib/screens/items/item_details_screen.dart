import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../services/supabase_service.dart';
import '../../components/theme2.dart'; // Import theme for consistent styling
import 'edit_item_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item item;

  const ItemDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Item _currentItem;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _loadItemDetails(); // Load fresh data when screen initializes
  }

  Future<void> _loadItemDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updatedItem = await _supabaseService.getItemById(_currentItem.id);

      if (updatedItem != null && mounted) {
        setState(() {
          _currentItem = updatedItem;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading item details: $e')),
        );
      }
    }
  }

  Future<void> _refreshItemDetails() async {
    return _loadItemDetails();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth > 600 ? 200.0 : 250.0; // Smaller height on larger screens

    return Scaffold(
      // Apply background decoration similar to landing page
      body: Container(
        decoration: context.backgroundDecoration,
        child: SafeArea(
          child: _isLoading ?
          const Center(child: CircularProgressIndicator(color: Colors.white)) :
          RefreshIndicator(
            onRefresh: _refreshItemDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar
                  AppBar(
                    title: Text(
                      _currentItem.type == ItemType.lost ? 'Lost Item Details' : 'Found Item Details',
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    actions: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditItemScreen(item: _currentItem),
                            ),
                          );

                          // Refresh item details when returning from edit screen
                          if (result == true) {
                            _refreshItemDetails();
                          }
                        },
                      ),
                    ],
                  ),

                  // Main content with padding
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image carousel - responsive size
                        Container(
                          height: imageHeight,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: _currentItem.imageUrls.isEmpty
                              ? Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 64),
                            ),
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: PageView.builder(
                              itemCount: _currentItem.imageUrls.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  _currentItem.imageUrls[index],
                                  fit: BoxFit.contain, // Changed to contain instead of cover
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, size: 64),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                        // Content card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status and date row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Status chip
                                  Chip(
                                    backgroundColor: _currentItem.status == ItemStatus.active
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.green.withOpacity(0.2),
                                    label: Text(
                                      _currentItem.status == ItemStatus.active ? 'Active' : 'Resolved',
                                      style: TextStyle(
                                        color: _currentItem.status == ItemStatus.active
                                            ? Colors.blue
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Date
                                  Text(
                                    '${_currentItem.date.day}/${_currentItem.date.month}/${_currentItem.date.year}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Title
                              Text(
                                _currentItem.title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Category
                              Row(
                                children: [
                                  const Icon(Icons.category, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    _currentItem.category,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Location
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _currentItem.location,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Description section
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentItem.description,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Contact section
                              const Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _currentItem.contactInfo,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Mark as resolved button
                              if (_currentItem.status == ItemStatus.active)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Show confirmation dialog
                                      final shouldMark = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Mark as Resolved'),
                                          content: Text(
                                            _currentItem.type == ItemType.lost
                                                ? 'Has this item been found and returned to you?'
                                                : 'Has this item been claimed by its owner?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldMark == true) {
                                        try {
                                          setState(() {
                                            _isLoading = true;
                                          });

                                          // Mark item as resolved
                                          await _supabaseService.markItemAsResolved(_currentItem);

                                          // Refresh item details
                                          await _refreshItemDetails();

                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Item marked as resolved'),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: Text(
                                      _currentItem.type == ItemType.lost
                                          ? 'Mark as Found'
                                          : 'Mark as Claimed',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}