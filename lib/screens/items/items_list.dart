import 'package:flutter/material.dart';
import 'package:mawjood/models/item_model.dart';
import 'package:mawjood/services/supabase_service.dart';
import 'package:mawjood/screens/items/item_details_screen.dart';
import 'package:mawjood/screens/items/edit_item_screen.dart';

class ItemsList extends StatefulWidget {
  final ItemType itemType;

  const ItemsList({Key? key, required this.itemType}) : super(key: key);

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  final SupabaseService _supabaseService = SupabaseService();
  late Stream<List<Item>> _itemsStream;

  @override
  void initState() {
    super.initState();
    _itemsStream = _supabaseService.getItems(widget.itemType);
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsStream = _supabaseService.getItems(widget.itemType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: StreamBuilder<List<Item>>(
        stream: _itemsStream,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.itemType == ItemType.lost
                        ? Icons.search_off
                        : Icons.help_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.itemType == ItemType.lost
                        ? 'No lost items reported yet'
                        : 'No found items reported yet',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to add an item!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Data loaded successfully
          final items = snapshot.data!;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ItemCard(
                item: item,
                onTap: () => _navigateToDetails(context, item),
                onEdit: () => _navigateToEdit(context, item),
                onDelete: () => _confirmDelete(context, item),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDetails(BuildContext context, Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(item: item),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Item item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: item),
      ),
    );

    if (result == true) {
      _refreshItems();
    }
  }

  Future<void> _confirmDelete(BuildContext context, Item item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _supabaseService.deleteItem(item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item deleted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting item: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            if (item.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    item.imageUrls.first,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Item details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        backgroundColor: item.status == ItemStatus.active
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        label: Text(
                          item.status == ItemStatus.active ? 'Active' : 'Resolved',
                          style: TextStyle(
                            color: item.status == ItemStatus.active
                                ? Colors.blue
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${item.date.day}/${item.date.month}/${item.date.year}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location and Category row
                  Row(
                    children: [
                      // Location
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.location,
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Category
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            const Icon(Icons.category, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.category,
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Edit button
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      // Delete button
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        tooltip: 'Delete',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}