class InputValidators {
  InputValidators._();

  static String? validateHandle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Handle is required';
    }
    final trimmed = value.trim();
    if (!trimmed.startsWith('@')) {
      return 'Handle must start with "@"';
    }
    if (trimmed.length < 3) {
      return 'Handle must be at least 3 characters long';
    }
    final handleRegex = RegExp(r'^@[a-zA-Z0-9_]{2,20}$');
    if (!handleRegex.hasMatch(trimmed)) {
      return 'Handle can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validateRollNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Roll number is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 4 || trimmed.length > 20) {
      return 'Roll number must be between 4 and 20 characters';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateSecurityAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Security answer cannot be empty';
    }
    if (value.trim().length < 2) {
      return 'Answer must be at least 2 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
