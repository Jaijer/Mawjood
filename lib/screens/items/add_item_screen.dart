import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../utils/form_validators.dart';
import './image_picker.dart';

class AddItemScreen extends StatefulWidget {
  final ItemType itemType;

  const AddItemScreen({
    super.key,
    required this.itemType,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = '';
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _contactInfoController = TextEditingController();
  List<String> _imageUrls = [];

  // Predefined categories for lost and found items
  final List<String> _lostCategories = [
    'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Other'
  ];
  final List<String> _foundCategories = [
    'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Other'
  ];

  List<String> get _categories {
    return widget.itemType == ItemType.lost ? _lostCategories : _foundCategories;
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

  void _handleImageSelected(String imageUrl) {
    setState(() {
      _imageUrls.add(imageUrl);
    });
  }

  void _handleImageRemoved(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image')),
        );
        return;
      }

      // Here you would normally save the item to the database
      // For now, we'll just show a success message

      // Print the item data to console for debugging
      print('Submitting item:');
      print('Title: ${_titleController.text}');
      print('Description: ${_descriptionController.text}');
      print('Category: $_selectedCategory');
      print('Location: ${_locationController.text}');
      print('Date: $_selectedDate');
      print('Contact Info: ${_contactInfoController.text}');
      print('Images: $_imageUrls');
      print('Type: ${widget.itemType}');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully')),
      );

      // Navigate back to the home screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemType == ItemType.lost ? 'Report Lost Item' : 'Report Found Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              CustomImagePicker(
                images: _imageUrls,
                onImageSelected: _handleImageSelected,
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
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
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

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}