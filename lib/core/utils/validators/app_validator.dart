class AppValidator {
  AppValidator._();

  /// Validates if a field is required and not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  /// Validates password with strength requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  /// Validates if password confirmation matches the original password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required.';
    }

    if (value != password) {
      return 'Passwords do not match.';
    }

    return null;
  }

  /// Validates phone number (10 digits)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // Regular expression for phone number validation (assuming a 10-digit US phone number format)
    final phoneRegExp = RegExp(r'^\d{10}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (10 digits required).';
    }

    return null;
  }

  /// Validates full name (at least 2 words)
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required.';
    }

    final trimmedValue = value.trim();

    // Check if name contains at least 2 words
    final words = trimmedValue.split(RegExp(r'\s+'));
    if (words.length < 2) {
      return 'Please enter your full name (first and last name).';
    }

    // Check if each word has at least 2 characters
    for (final word in words) {
      if (word.length < 2) {
        return 'Each name must have at least 2 characters.';
      }
    }

    return null;
  }

  /// Validates price (must be a positive number)
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required.';
    }

    final price = double.tryParse(value);

    if (price == null) {
      return 'Please enter a valid price.';
    }

    if (price <= 0) {
      return 'Price must be greater than zero.';
    }

    return null;
  }
}
