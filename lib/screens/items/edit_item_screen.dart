import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../utils/form_validators.dart';
import './image_picker.dart';
import '../../services/supabase_service.dart';

class EditItemScreen extends StatefulWidget {
  final Item item;

  const EditItemScreen({
    super.key,
    required this.item,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  // Form fields
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  late TextEditingController _contactInfoController;
  late List<String> _imageUrls;
  late List<File> _imageFiles = [];
  late ItemStatus _status;

  // Predefined categories for lost and found items
  final List<String> _lostCategories = [
    'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Other'
  ];
  final List<String> _foundCategories = [
    'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Other'
  ];

  List<String> get _categories {
    return widget.item.type == ItemType.lost ? _lostCategories : _foundCategories;
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing item data
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(text: widget.item.description);
    _selectedCategory = widget.item.category;
    _locationController = TextEditingController(text: widget.item.location);
    _selectedDate = widget.item.date;
    _contactInfoController = TextEditingController(text: widget.item.contactInfo);
    _imageUrls = List.from(widget.item.imageUrls);
    _status = widget.item.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleFileSelected(File file) {
    setState(() {
      _imageFiles.add(file);
    });
  }

  void _handleImageRemoved(int index) {
    if (index < _imageUrls.length) {
      setState(() {
        _imageUrls.removeAt(index);
      });
    } else {
      setState(() {
        _imageFiles.removeAt(index - _imageUrls.length);
      });
    }
  }

  Future<void> _updateItem() async {
    if (_formKey.currentState!.validate()) {
      if (_imageUrls.isEmpty && _imageFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Upload new images to Supabase storage
        List<String> newImageUrls = [];
        for (File file in _imageFiles) {
          final imageUrl = await _supabaseService.uploadImage(file);
          newImageUrls.add(imageUrl);
        }

        // Combine existing and new image URLs
        final allImageUrls = [..._imageUrls, ...newImageUrls];

        // Create updated item
        final updatedItem = widget.item.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          location: _locationController.text,
          date: _selectedDate,
          contactInfo: _contactInfoController.text,
          imageUrls: allImageUrls,
          status: _status,
        );

        // Update the item in Supabase
        await _supabaseService.updateItem(updatedItem);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item updated successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating item: $e')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.type == ItemType.lost ? 'Edit Lost Item' : 'Edit Found Item'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              CustomImagePicker(
                imageFiles: _imageFiles,
                imageUrls: _imageUrls,
                onFileSelected: _handleFileSelected,
                onImageRemoved: _handleImageRemoved,
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief description of the item',
                ),
                validator: FormValidators.validateTitle,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Detailed description of the item',
                ),
                maxLines: 3,
                validator: FormValidators.validateDescription,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Select a category',
                ),
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
                validator: FormValidators.validateCategory,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where was the item lost/found?',
                ),
                validator: FormValidators.validateLocation,
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Contact info
              TextFormField(
                controller: _contactInfoController,
                decoration: const InputDecoration(
                  labelText: 'Contact Information',
                  hintText: 'How can others reach you?',
                ),
                validator: FormValidators.validateContactInfo,
              ),
              const SizedBox(height: 24),

              // Status toggle
              SwitchListTile(
                title: const Text('Mark as Resolved'),
                subtitle: const Text('Toggle if the item has been returned'),
                value: _status == ItemStatus.resolved,
                onChanged: (bool value) {
                  setState(() {
                    _status = value ? ItemStatus.resolved : ItemStatus.active;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Update', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}