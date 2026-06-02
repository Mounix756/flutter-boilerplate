class AuthErrorSanitizer {
  static final RegExp _emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );
  static final RegExp _longNumberPattern = RegExp(r'\b\d{4,}\b');

  static String sanitizeForDisplay(String input) {
    return input
        .replaceAll(_longNumberPattern, '****')
        .replaceAll(_emailPattern, '****@****.***');
  }
}
