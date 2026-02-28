import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import '../data/providers.dart';

import 'dart:async';

import '../theme/colors.dart';
import '../theme/constants.dart';
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
                    'Already have an account?',
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
                    emoji: '🤖',
                    title: 'AI-friend nearby',
                    description: 'A smart bot will help with homework, deadlines, and advice.',
                  ),
                  _OnboardingPage(
                    emoji: '📚',
                    title: 'Manage your schedule',
                    description: 'The entire schedule in one place. Never miss a substitution again!',
                  ),
                  _OnboardingPage(
                    emoji: '💬',
                    title: 'Reviews about teachers',
                    description: 'Get to know your teachers before your first lesson with them!',
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
                text: 'Start',
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

    try {
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
    } catch (e) {
      debugPrint('Headman verification error: $e');
    }
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
                'Your role',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                emoji: '♟️',
                title: 'Student',
                description: 'Manage personal expenses, view calendar, news',
                isSelected: _role == 'student',
                onTap: () => setState(() => _role = 'student'),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: _isHeadmanTaken ? 0.5 : 1.0,
                child: _RoleCard(
                  emoji: '👑',
                  title: _isHeadmanTaken ? 'Headman (already taken)' : 'Headman',
                  description: _isHeadmanTaken
                      ? 'This group already has a headman.'
                      : 'Basic functions + schedule and group management',
                  isSelected: _role == 'headman',
                  onTap: _isHeadmanTaken
                      ? () {}
                      : () => setState(() => _role = 'headman'),
                ),
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
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),

              CustomTextField(
                label: 'Full name',
                hint: '...',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter your full name';
                  final words = value.trim().split(RegExp(r'\s+'));
                  if (words.length < 2) {
                    return 'Last name and first name are required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'E-mail',
                hint: '...',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
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
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (value.length < 8) {
                    return 'Must contain at least 8 characters';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Must contain at least one capital letter';
                  }
                  if (!RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]').hasMatch(value)) {
                    return 'Must contain at least one special symbol';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Confirm password',
                hint: '...',
                controller: _confirmPasswordController,
                obscureText: true,
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
