import 'package:flutter/material.dart';
import 'package:mawjood/models/item_model.dart';
import 'package:mawjood/screens/items/image_picker.dart';
import 'package:mawjood/services/firestore_service.dart';
import 'package:mawjood/utils/form_validators.dart';
import 'package:uuid/uuid.dart';

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
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactInfoController = TextEditingController();

  // Form state
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  List<String> _imageUrls = [];

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
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    try {
      final newItem = Item(
        id: _uuid.v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        location: _locationController.text,
        date: _selectedDate,
        imageUrls: _imageUrls,
        userId: 'current_user_id', // Replace with actual user ID
        contactInfo: _contactInfoController.text,
        type: widget.itemType,
      );

      await _firestoreService.addItem(newItem);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
                images: _imageUrls,
                onImageSelected: (imageUrl) =>
                    setState(() => _imageUrls.add(imageUrl)),
                onImageRemoved: (index) =>
                    setState(() => _imageUrls.removeAt(index)),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date*'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
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
