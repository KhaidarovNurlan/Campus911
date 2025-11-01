import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

/// 🔐 Экран авторизации с онбордингом
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
            ? const _AuthForm()
            : _OnboardingScreen(
                controller: _onboardingController,
                onComplete: () => setState(() => _showAuth = true),
              ),
      ),
    );
  }
}

// ========== ОНБОРДИНГ ==========

class _OnboardingScreen extends StatelessWidget {
  final PageController controller;
  final VoidCallback onComplete;

  const _OnboardingScreen({required this.controller, required this.onComplete});

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
            // Кнопка "Пропустить"
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: onComplete,
                  child: Text(
                    'Пропустить',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Страницы онбординга
            Expanded(
              child: PageView(
                controller: controller,
                children: [
                  _OnboardingPage(
                    emoji: '📚',
                    title: 'Управляй расписанием',
                    description:
                        'Всё расписание в одном месте. Никогда не пропусти пару!',
                  ),
                  _OnboardingPage(
                    emoji: '💬',
                    title: 'Общайся с группой',
                    description:
                        'Чаты с одногруппниками, обмен файлами и новостями.',
                  ),
                  _OnboardingPage(
                    emoji: '🤖',
                    title: 'AI-помощник рядом',
                    description:
                        'Умный бот поможет с расписанием, дедлайнами и советами.',
                  ),
                ],
              ),
            ),

            // Индикатор страниц
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.secondary.withValues(alpha: 0.3),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 4,
                ),
              ),
            ),

            // Кнопка "Начать"
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Начать',
                onPressed: onComplete,
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

// ========== ФОРМА РЕГИСТРАЦИИ ==========

class _AuthForm extends StatefulWidget {
  const _AuthForm();

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Контроллеры
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Выбранные значения
  String _role = 'student';
  String _gender = 'Мужской';
  String _university = 'AITU';

  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _progress => (_currentStep + 1) / 4;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Имитация регистрации (задержка 2 сек)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Создаём пользователя
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      university: _university,
      gender: _gender,
      role: _role,
    );

    // Сохраняем в провайдере
    context.read<UserProvider>().setUser(user);

    setState(() => _isLoading = false);

    // Переходим на главный экран
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _previousStep,
              )
            : null,
        title: const Text('Регистрация'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: isDark
                ? AppColors.darkSurface
                : AppColors.background,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Role(
                    selectedRole: _role,
                    onRoleChanged: (role) => setState(() => _role = role),
                  ),
                  _Step2PersonalInfo(
                    nameController: _nameController,
                    selectedGender: _gender,
                    onGenderChanged: (gender) =>
                        setState(() => _gender = gender),
                  ),
                  _Step3Contacts(
                    emailController: _emailController,
                    phoneController: _phoneController,
                  ),
                  _Step4University(
                    selectedUniversity: _university,
                    onUniversityChanged: (uni) =>
                        setState(() => _university = uni),
                  ),
                ],
              ),
            ),

            // Кнопка "Далее"
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: _currentStep == 3 ? 'Завершить регистрацию' : 'Далее',
                onPressed: _nextStep,
                isLoading: _isLoading,
                icon: _currentStep == 3
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== ШАГ 1: ВЫБОР РОЛИ ==========

class _Step1Role extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const _Step1Role({required this.selectedRole, required this.onRoleChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите роль',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Это повлияет на доступные функции',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),

          _RoleCard(
            emoji: '🎓',
            title: 'Гражданский (Студент)',
            description: 'Просмотр расписания, чаты, трекер расходов',
            isSelected: selectedRole == 'student',
            onTap: () => onRoleChanged('student'),
          ),
          const SizedBox(height: 16),
          _RoleCard(
            emoji: '👑',
            title: 'Глава (Староста)',
            description:
                'Все функции студента + управление расписанием и посещаемостью',
            isSelected: selectedRole == 'headman',
            onTap: () => onRoleChanged('headman'),
          ),
        ],
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

// ========== ШАГ 2: ЛИЧНАЯ ИНФОРМАЦИЯ ==========

class _Step2PersonalInfo extends StatelessWidget {
  final TextEditingController nameController;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const _Step2PersonalInfo({
    required this.nameController,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Личная информация',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Расскажите немного о себе',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            label: 'ФИО',
            hint: 'Иванов Иван Иванович',
            controller: nameController,
            prefixIcon: const Icon(Icons.person_rounded),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите ваше имя';
              }
              if (value.split(' ').length < 2) {
                return 'Введите полное имя (Фамилия Имя)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Гендер',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textLight
                  : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.genders.map((gender) {
                final isSelected = selectedGender == gender;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(gender),
                    selected: isSelected,
                    onSelected: (selected) => onGenderChanged(gender),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : AppColors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textGrey,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textGrey.withValues(alpha: 0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== ШАГ 3: КОНТАКТЫ ==========

class _Step3Contacts extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const _Step3Contacts({
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Контактная информация',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Как с вами связаться?',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            label: 'Email',
            hint: 'example@aitu.edu.kz',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_rounded),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите email';
              }
              if (!AppConstants.emailRegex.hasMatch(value)) {
                return 'Введите корректный email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          CustomTextField(
            label: 'Номер телефона',
            hint: '+7 (777) 123-45-67',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_rounded),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PhoneInputFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите номер телефона';
              }
              if (!AppConstants.phoneRegex.hasMatch(value)) {
                return 'Введите корректный номер';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

// Форматтер для телефона
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '+7 ';

    if (text.length > 1) {
      formatted += '(${text.substring(1, text.length > 4 ? 4 : text.length)}';
    }

    if (text.length >= 4) {
      formatted += ') ${text.substring(4, text.length > 7 ? 7 : text.length)}';
    }

    if (text.length >= 7) {
      formatted += '-${text.substring(7, text.length > 9 ? 9 : text.length)}';
    }

    if (text.length >= 9) {
      formatted += '-${text.substring(9, text.length > 11 ? 11 : text.length)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ========== ШАГ 4: УНИВЕРСИТЕТ ==========

class _Step4University extends StatelessWidget {
  final String selectedUniversity;
  final ValueChanged<String> onUniversityChanged;

  const _Step4University({
    required this.selectedUniversity,
    required this.onUniversityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Учебное заведение',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите ваш колледж или университет',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),

          DropdownButtonFormField<String>(
            initialValue: selectedUniversity,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Университет',
              prefixIcon: Icon(Icons.school_rounded),
            ),
            items: AppConstants.universities.map((uni) {
              return DropdownMenuItem(
                value: uni,
                child: Text(
                  uni,
                  overflow: TextOverflow.ellipsis, // ПОДРЕДАЧ!
                  maxLines: 1, // ПОДРЕДАЧ!
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onUniversityChanged(value);
            },
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Вы будете видеть только расписание и новости выбранного учебного заведения',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
