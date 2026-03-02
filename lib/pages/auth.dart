import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/providers.dart';

import '../theme/colors.dart';
import '../theme/constants.dart';
import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthForm();
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm();

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _confirmPassFocus = FocusNode();

  String _role = 'student';
  late String _college;
  String? _selectedGroup;
  late List<String> _currentGroups;

  bool _isLoading = false;
  bool _isHeadmanTaken = false;

  @override
  void initState() {
    super.initState();
    _college = AppConstants.collegesWithGroups.keys.first;
    _currentGroups = AppConstants.collegesWithGroups[_college]!;
    _selectedGroup = _currentGroups.first;

    _checkHeadmanAvailability();
  }

  Future<void> _checkHeadmanAvailability() async {
    if (_selectedGroup == null) return;

    final bool isTaken = await context.read<UserProvider>().checkGroupHeadman(
    _college,
    _selectedGroup!,
    );

    setState(() {
    _isHeadmanTaken = isTaken;
    if (_isHeadmanTaken && _role == 'headman') {
        _role = 'student';
    }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<UserProvider>().authorize(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        college: _college,
        group: _selectedGroup!,
        role: _role,
      );

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorization'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      emoji: '♟️',
                      title: 'Student',
                      isSelected: _role == 'student',
                      onTap: () => setState(() => _role = 'student'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: _isHeadmanTaken ? 0.5 : 1.0,
                      child: _RoleCard(
                        emoji: '👑',
                        title: 'Headman',
                        isSelected: _role == 'headman',
                        onTap: _isHeadmanTaken
                            ? () {}
                            : () => setState(() => _role = 'headman'),
                        subtitle: _isHeadmanTaken ? 'Taken' : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              DropdownButtonFormField<String>(
                initialValue: _college,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'College',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: AppConstants.collegesWithGroups.keys.map((coll) {
                  return DropdownMenuItem(value: coll, child: Text(coll));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _college = value;
                      _currentGroups = AppConstants.collegesWithGroups[_college]!;
                      _selectedGroup = _currentGroups.first;
                    });
                    _checkHeadmanAvailability();
                  }
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _selectedGroup,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  prefixIcon: Icon(Icons.group_outlined),
                ),
                items: _currentGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGroup = value);
                  _checkHeadmanAvailability();
                },
                validator: (value) => value == null ? 'Choose your group' : null,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),

              CustomTextField(
                label: 'Full name',
                hint: '...',
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                prefixIcon: const Icon(Icons.person_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter your full name';
                  final words = value.trim().split(RegExp(r'\s+'));
                  if (words.length < 2) return 'Last name and first name are required';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'E-mail',
                hint: '...',
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passFocus),
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter e-mail';
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) return 'Incorrect e-mail';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Password',
                hint: '...',
                isPassword: true,
                controller: _passwordController,
                focusNode: _passFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPassFocus),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (value.length < 8) return 'Must contain at least 8 characters';
                  if (!RegExp(r'[A-Z]').hasMatch(value)) return 'At least one capital letter';
                  if (!RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]').hasMatch(value)) return 'At least one special symbol';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Confirm password',
                hint: '...',
                isPassword: true,
                controller: _confirmPasswordController,
                focusNode: _confirmPassFocus,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                validator: (value) {
                  if (value != _passwordController.text) return 'The passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Create an account',
                onPressed: _register,
                isLoading: _isLoading,
                icon: Icons.person_add_alt_1_rounded,
              ),
              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGrey,
                      ),
                      children: [
                        TextSpan(
                          text: 'Log In',
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

class _RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.textLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.textGrey.withValues(alpha: 0.2)
                    : AppColors.divider),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 10, color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }
}
