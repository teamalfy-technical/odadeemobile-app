import 'package:flutter_test/flutter_test.dart';
import 'package:odadee/utils/password_policy.dart';

void main() {
  group('PasswordPolicy', () {
    test('accepts a password matching the backend policy', () {
      expect(PasswordPolicy.validate('Correct1!'), isNull);
    });

    test('rejects missing character classes', () {
      expect(PasswordPolicy.validate('lowercase1!'), contains('uppercase'));
      expect(PasswordPolicy.validate('UPPERCASE1!'), contains('lowercase'));
      expect(PasswordPolicy.validate('NoNumber!'), contains('number'));
      expect(PasswordPolicy.validate('NoSpecial1'), contains('special'));
    });

    test('enforces the backend 8 to 128 character limits', () {
      expect(PasswordPolicy.validate('Aa1!'), contains('at least 8'));

      final maximumLengthPassword = 'Aa1!${List.filled(124, 'x').join()}';
      expect(maximumLengthPassword.length, PasswordPolicy.maxLength);
      expect(PasswordPolicy.validate(maximumLengthPassword), isNull);

      final tooLongPassword = '$maximumLengthPassword!';
      expect(PasswordPolicy.validate(tooLongPassword), contains('128'));
    });
  });
}
