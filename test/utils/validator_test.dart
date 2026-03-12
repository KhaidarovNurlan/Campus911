import 'package:flutter_test/flutter_test.dart';
import 'package:campus911/utils/validator.dart';

void main() {
  group('Validator Tests', () {
    test('Empty email returns error', () {
      final result = Validator.validateEmail('');
      expect(result, 'Enter e-mail');
    });

    test('Incorrect email returns error', () {
      final result = Validator.validateEmail('test.com');
      expect(result, 'Incorrect e-mail');
    });

    test('Valid email returns null', () {
      final result = Validator.validateEmail('test@gmail.com');
      expect(result, null);
    });

    test('Null value returns error', () {
      expect(Validator.validateEmail(null), 'Enter e-mail');
    });
  });
}