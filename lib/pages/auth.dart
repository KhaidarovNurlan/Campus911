import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../theme/colors.dart';
import '../core/constants.dart';
import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _onboardingController = PageController();
  bool _showAuth = false;

  @override
  void dispose() {
    _onboardingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showAuth
            ? _AuthForm(onBack: () => setState(() => _showAuth = false))
            : _OnboardingScreen(
                controller: _onboardingController,
                onComplete: () => setState(() => _showAuth = true),
              ),
      ),
    );
  }
}

class _OnboardingScreen extends StatefulWidget {
  final PageController controller;
  final VoidCallback onComplete;

  const _OnboardingScreen({required this.controller, required this.onComplete});

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  Timer? _timer;
  final int _numPages = 3;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (widget.controller.hasClients) {
        int nextPage = widget.controller.page!.toInt() + 1;

        if (nextPage >= _numPages) {
          nextPage = 0;
        }

        widget.controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkGradient : null,
        color: isDark ? null : AppColors.background,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Уже есть аккаунт?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: widget.controller,
                children: [
                  _OnboardingPage(
                    emoji: '📚',
                    title: 'Управляй расписанием',
                    description: 'Всё расписание в одном месте. Никогда не пропусти пару!',
                  ),
                  _OnboardingPage(
                    emoji: '💬',
                    title: 'Общайся с группой',
                    description: 'Чаты с одногруппниками, обмен файлами и новостями.',
                  ),
                  _OnboardingPage(
                    emoji: '🤖',
                    title: 'AI-помощник рядом',
                    description: 'Умный бот поможет с расписанием, дедлайнами и советами.',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: widget.controller,
                count: _numPages,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.secondary.withValues(alpha: 0.3),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 4,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Начать',
                onPressed: widget.onComplete,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 120)),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AuthForm extends StatefulWidget {
  final VoidCallback onBack;

  const _AuthForm({required this.onBack});

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _role = 'student';
  late String _college;
  String? _selectedGroup;
  late List<String> _currentGroups;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _college = AppConstants.collegesWithGroups.keys.first;
    _currentGroups = AppConstants.collegesWithGroups[_college]!;
    _selectedGroup = _currentGroups.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'college': _college,
          'groupName': _selectedGroup,
          'role': _role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ошибка регистрации';
      if (e.code == 'email-already-in-use') message = 'Этот email уже используется';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ваша роль',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                emoji: '♟️',
                title: 'Обычный студент',
                description: 'Управление личными расходами, просмотр календаря, новостей',
                isSelected: _role == 'student',
                onTap: () => setState(() => _role = 'student'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                emoji: '👑',
                title: 'Староста группы',
                description: 'Базовые функции + управление раписанием, группой',
                isSelected: _role == 'headman',
                onTap: () => setState(() => _role = 'headman'),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(),
              ),

              DropdownButtonFormField<String>(
                initialValue: _college,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Колледж',
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
                  }
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _selectedGroup,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Группа',
                  prefixIcon: Icon(Icons.group_outlined),
                ),
                items: _currentGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGroup = value);
                },
                validator: (value) => value == null ? 'Выберите группу' : null,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                label: 'ФИО',
                hint: '...',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите ФИО';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Электронная почта',
                hint: '...',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите email';
                  if (!AppConstants.emailRegex.hasMatch(value)) return 'Некорректный email';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Пароль',
                hint: '...',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 8) {
                    return 'Пароль должен содержать минимум 8 символов';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Пароль должен содержать заглавную букву';
                  }
                  if (!RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]').hasMatch(value)) {
                    return 'Пароль должен содержать специальный символ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Повторите пароль',
                hint: '...',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                validator: (value) {
                  if (value != _passwordController.text) return 'Пароли не совпадают';
                  return null;
                },
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Создать аккаунт',
                onPressed: _register,
                isLoading: _isLoading,
                icon: Icons.person_add_alt_1_rounded,
              ),
              const SizedBox(height: 40),
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
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                      ? AppColors.textGrey.withValues(alpha: 0.2)
                      : AppColors.divider),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
