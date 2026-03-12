class Validator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Enter your full name';
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.length < 2) return 'Last name and first name are required';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter e-mail';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Incorrect e-mail';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';
    if (value.length < 8) return 'Must contain at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'At least one capital letter';
    if (!RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]').hasMatch(value)) {
      return 'At least one special symbol';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) return 'Confirm password';
    if (value != originalPassword) return 'The passwords do not match';
    return null;
  }
}