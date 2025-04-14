class FormValidators {
  // Title validator
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.length > 50) {
      return 'Title must be less than 50 characters';
    }
    return null;
  }

  // Description validator
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  // Category validator
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  // Location validator
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a location';
    }
    return null;
  }

  // Contact info validator
  static String? validateContactInfo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter contact information';
    }
    return null;
  }

  // Image validator
  static String? validateImages(List<String>? value) {
    if (value == null || value.isEmpty) {
      return 'Please add at least one image';
    }
    return null;
  }
}