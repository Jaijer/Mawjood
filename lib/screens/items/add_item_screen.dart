import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mawjood/models/item_model.dart';
import 'package:mawjood/screens/items/image_picker.dart';
import 'package:mawjood/services/supabase_service.dart';
import 'package:mawjood/utils/form_validators.dart';
import 'package:uuid/uuid.dart';
import '../../config/supabase_config.dart';

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
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactInfoController = TextEditingController();

  // Form state
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  List<XFile> _imageFiles = [];
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload images to Supabase storage
      List<String> imageUrls = [];
      for (XFile file in _imageFiles) {
        final imageUrl = await _supabaseService.uploadImage(file);
        imageUrls.add(imageUrl);
      }

      // Get current user id from Supabase
      final userId = SupabaseConfig.client.auth.currentUser?.id ?? 'anonymous_user';

      final newItem = Item(
        id: _uuid.v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        location: _locationController.text.trim(),
        date: _selectedDate,
        imageUrls: imageUrls,
        userId: userId,
        contactInfo: _contactInfoController.text.trim(),
        type: widget.itemType,
        status: ItemStatus.active,
      );

      await _supabaseService.addItem(newItem);

      if (!mounted) return;

      // Return true to indicate successful creation
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleFileSelected(XFile file) {
    setState(() {
      _imageFiles.add(file);
    });
  }

  void _handleImageRemoved(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemType == ItemType.lost
            ? 'Report Lost Item'
            : 'Report Found Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImagePicker(
                imageFiles: _imageFiles,
                imageUrls: const [],
                onFileSelected: _handleFileSelected,
                onImageRemoved: _handleImageRemoved,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  hintText: 'Brief description of the item',
                ),
                validator: FormValidators.validateTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  hintText: 'Detailed description of the item',
                ),
                maxLines: 3,
                validator: FormValidators.validateDescription,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category*',
                ),
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
                validator: FormValidators.validateCategory,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location*',
                  hintText: 'Where was the item lost/found?',
                ),
                validator: FormValidators.validateLocation,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date*',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactInfoController,
                decoration: const InputDecoration(
                  labelText: 'Contact Information*',
                  hintText: 'How can others reach you?',
                ),
                validator: FormValidators.validateContactInfo,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}