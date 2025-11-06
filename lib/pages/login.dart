import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';
import '../data/user_service.dart';
import '../data/providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;

      final credential = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null) {
        final userService = UserService();
        final userModel = await userService.fetchCurrentUser();

        if (userModel != null && mounted) {
          context.read<UserProvider>().setUser(userModel);

          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось загрузить данные пользователя'),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ошибка входа';
      if (e.code == 'user-not-found') message = 'Пользователь не найден';
      if (e.code == 'wrong-password') {
        message = 'Неверный пароль (временно 12345678)';
      }
      if (e.code == 'invalid-email') message = 'Некорректный email';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход в аккаунт')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              label: 'Email',
              hint: 'example@aitu.edu.kz',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_rounded),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Пароль',
              hint: 'Введите пароль',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_rounded),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Войти',
              onPressed: _login,
              isLoading: _isLoading,
              icon: Icons.login_rounded,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/auth'),
              child: const Text('← Вернуться к регистрации'),
            ),
          ],
        ),
      ),
    );
  }
}
