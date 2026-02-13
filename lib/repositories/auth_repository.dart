import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    // Добавляем ручную проверку: если email или пароль пустые,
    // сразу возвращаем null, не дожидаясь ответа от Firebase
    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}