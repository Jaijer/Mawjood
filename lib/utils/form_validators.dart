// lib/utils/form_validators.dart

class FormValidators {
  // Validate title
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.length > 50) {
      return 'Title cannot exceed 50 characters';
    }
    return null;
  }

  // Validate description
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (value.length > 500) {
      return 'Description cannot exceed 500 characters';
    }
    return null;
  }

  // Validate category
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  // Validate location
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a location';
    }
    if (value.length < 3) {
      return 'Location must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Location cannot exceed 100 characters';
    }
    return null;
  }

  // Validate contact info
  static String? validateContactInfo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter contact information';
    }

    // Check if it's a valid email
    bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);

    // Check if it's a valid phone number (simple check)
    bool isPhone = RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value);

    // If contact info is not a valid email or phone, suggest formatting
    if (!isEmail && !isPhone && value.length < 8) {
      return 'Please provide a valid email or phone number';
    }

    return null;
  }

  // Validate images
  static String? validateImages(List<String> images) {
    if (images.isEmpty) {
      return 'Please add at least one image';
    }
    return null;
  }
}