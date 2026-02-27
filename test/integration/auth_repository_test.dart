import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:campus911/utils/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Успешный вход обновляет state пользователя', () async {
    final user = MockUser(
      isAnonymous: false,
      uid: 'some_uid',
      email: 'test@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user);
    final repository = AuthRepository(auth: mockAuth);
    await repository.signIn('test@example.com', 'password123');
    expect(mockAuth.currentUser, isNotNull);
    expect(mockAuth.currentUser!.email, 'test@example.com');
  });

  test('Выход из аккаунта очищает данные прошлого user-а', () async {
    final mockAuth = MockFirebaseAuth(signedIn: true);
    final repository = AuthRepository(auth: mockAuth);
    await repository.signOut();
    expect(mockAuth.currentUser, isNull);
  });

  test('Сохранение флага первого входа в SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    final isLoggedIn = prefs.getBool('is_logged_in');
    expect(isLoggedIn, true);
  });
}