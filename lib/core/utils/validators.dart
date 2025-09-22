class Validators {
  static String? validateNotEmpty(String? value) {
    return (value == null || value.isEmpty) ? 'Required' : null;
  }

  static bool isValidPublicKey(String value) {
    return value.startsWith('0x') && value.length == 42;
  }

  static bool isStrongPassword(String value) {
    final hasMinLength = value.length >= 8;
    final hasNumber = value.contains(RegExp(r'\d'));
    final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    return hasMinLength && hasNumber && hasLetter;
  }
}
