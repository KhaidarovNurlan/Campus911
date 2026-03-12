import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/colors.dart';
import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';
import '../data/providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<UserProvider>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('invalid-credential')) {
            _emailError = 'Invalid email or password';
            _passwordError = 'Invalid email or password';
          } else if (e.toString().contains('network-request-failed')) {
            _emailError = 'No internet connection';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An error occurred. Please try again.')),
            );
          }
        });
      }

      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CustomTextField(
                label: 'E-mail',
                hint: '...',
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passFocus),
                prefixIcon: const Icon(Icons.email_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter e-mail';
                  if (_emailError != null) return _emailError;
                  return null;
                },
                onChanged: (value) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Password',
                hint: '...',
                isPassword: true,
                controller: _passwordController,
                focusNode: _passFocus,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (_passwordError != null) return _passwordError;
                  return null;
                },
                onChanged: (value) {
                  if (_passwordError != null) setState(() => _passwordError = null);
                },
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Enter an account',
                onPressed: _login,
                isLoading: _isLoading,
                icon: Icons.login_rounded,
              ),
              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Do not have an account yet? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGrey,
                      ),
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
