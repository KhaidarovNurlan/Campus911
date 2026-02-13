import 'package:flutter_test/flutter_test.dart';
import 'package:campus911/utils/validator.dart';

void main() {
  group('Валидация почты', () {
    test('Возвращает пустой email', () {
      final result = Validator.validateEmail('');
      expect(result, 'Нужен email');
    });

    test('Неалидная почта возвращает ошибку', () {
      final result = Validator.validateEmail('invalid-email');
      expect(result, 'Введите валидную почту');
    });

    test('Почта является null', () {
      final result = Validator.validateEmail('test@mail.com');
      expect(result, null);
    });

    test('Пароль меньше 8 символов возвращает ошибку', () {
      final result = Validator.validatePassword('123');
      expect(result, 'Пароль должен быть минимум 8 символов');
    });
  });
}