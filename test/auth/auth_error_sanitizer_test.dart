import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate/features/auth/utils/auth_error_sanitizer.dart';

void main() {
  test('sanitizeForDisplay masks emails and long numeric sequences', () {
    final result = AuthErrorSanitizer.sanitizeForDisplay(
      'Code 123456 envoyé à jane.doe@example.com',
    );

    expect(result, contains('****'));
    expect(result, isNot(contains('123456')));
    expect(result, isNot(contains('jane.doe@example.com')));
  });
}
