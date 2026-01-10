class Validators {
  /// Validate site name (non-empty)
  static String? validateSiteName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Site name is required';
    }
    return null;
  }

  /// Validate username/email (non-empty)
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username/Email is required';
    }
    return null;
  }

  /// Validate password (non-empty, minimum length)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 3) {
      return 'Password must be at least 3 characters';
    }
    return null;
  }

  /// Validate PIN (4-8 digits only)
  static String? validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    
    if (value.length < 4 || value.length > 8) {
      return 'PIN must be 4-8 digits';
    }
    
    return null;
  }

  /// Validate notes (optional, no validation needed)
  static String? validateNotes(String? value) {
    // Notes are optional
    return null;
  }
}
