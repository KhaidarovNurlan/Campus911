import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../services/firestore_service.dart';

/// 📅 Экран расписания
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final firestore = FirestoreService();
    final lessons = await firestore.getLessons();
    final provider = context.read<ScheduleProvider>();

    provider.clearLessons();
    for (var lesson in lessons) {
      provider.addLesson(lesson);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHeadman = userProvider.isHeadman;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Расписание'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          tabs: AppConstants.weekDays.map((day) {
            return Tab(text: day.substring(0, 2)); // Пн, Вт, Ср...
          }).toList(),
        ),
        actions: [
          if (isHeadman)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Добавить занятие',
              onPressed: () => _showAddLessonDialog(context),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: 7,
        onPageChanged: (index) {
          setState(() => _currentDayIndex = index);
          _tabController.animateTo(index);
        },
        itemBuilder: (context, index) {
          return _DaySchedule(
            day: AppConstants.weekDays[index],
            isHeadman: isHeadman,
          );
        },
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddLessonBottomSheet(
        selectedDay: AppConstants.weekDays[_currentDayIndex],
      ),
    );
  }
}

// ========== РАСПИСАНИЕ НА ДЕНЬ ==========

class _DaySchedule extends StatelessWidget {
  final String day;
  final bool isHeadman;

  const _DaySchedule({required this.day, required this.isHeadman});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final lessons = scheduleProvider.getLessonsForDay(day);

    if (lessons.isEmpty) {
      return _EmptySchedule(day: day, isHeadman: isHeadman);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return _LessonCard(lesson: lessons[index], isHeadman: isHeadman);
      },
    );
  }
}

// Карточка занятия
class _LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final bool isHeadman;

  const _LessonCard({required this.lesson, required this.isHeadman});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isHeadman ? () => _showLessonOptions(context) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getLessonColor(lesson.type).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Цветовая полоска слева
              Container(
                width: 6,
                height: 120,
                decoration: BoxDecoration(
                  color: _getLessonColor(lesson.type),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // Время
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(lesson.startTime),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getLessonColor(lesson.type),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 20,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.textGrey.withValues(alpha: 0.3),
                    ),
                    Text(
                      DateFormat('HH:mm').format(lesson.endTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),

              // Вертикальный разделитель
              Container(width: 1, height: 80, color: AppColors.divider),

              // Информация о занятии
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.subject,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getLessonColor(
                                lesson.type,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lesson.typeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getLessonColor(lesson.type),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _LessonInfo(
                        icon: Icons.person_rounded,
                        text: lesson.teacher,
                      ),
                      const SizedBox(height: 4),
                      _LessonInfo(
                        icon: Icons.room_rounded,
                        text: 'Каб. ${lesson.room}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLessonColor(String type) {
    switch (type) {
      case 'lecture':
        return AppColors.primary;
      case 'practice':
        return AppColors.secondary;
      case 'lab':
        return AppColors.info;
      default:
        return AppColors.textGrey;
    }
  }

  void _showLessonOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LessonOptionsSheet(lesson: lesson),
    );
  }
}

class _LessonInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LessonInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Пустое расписание
class _EmptySchedule extends StatelessWidget {
  final String day;
  final bool isHeadman;

  const _EmptySchedule({required this.day, required this.isHeadman});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 80,
              color: AppColors.textGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Расписание на $day\nпока не добавлено',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
            if (isHeadman) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Добавить занятие',
                onPressed: () => _showAddLessonDialog(context, day),
                icon: Icons.add_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context, String day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddLessonBottomSheet(selectedDay: day),
    );
  }
}

// ========== МОДАЛЬНОЕ ОКНО ДОБАВЛЕНИЯ ЗАНЯТИЯ ==========

class _AddLessonBottomSheet extends StatefulWidget {
  final String selectedDay;

  const _AddLessonBottomSheet({required this.selectedDay});

  @override
  State<_AddLessonBottomSheet> createState() => _AddLessonBottomSheetState();
}

class _AddLessonBottomSheetState extends State<_AddLessonBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();

  String _selectedType = 'lecture';
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 30);

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Добавить занятие',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          widget.selectedDay,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Предмет
              CustomTextField(
                label: 'Предмет',
                hint: 'Математика',
                controller: _subjectController,
                prefixIcon: const Icon(Icons.book_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название предмета';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Преподаватель
              CustomTextField(
                label: 'Преподаватель',
                hint: 'Иванов И.И.',
                controller: _teacherController,
                prefixIcon: const Icon(Icons.person_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ФИО преподавателя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Кабинет
              CustomTextField(
                label: 'Кабинет',
                hint: '305',
                controller: _roomController,
                prefixIcon: const Icon(Icons.room_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите номер кабинета';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Тип занятия
              Text(
                'Тип занятия',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _TypeChip(
                    label: 'Лекция',
                    value: 'lecture',
                    groupValue: _selectedType,
                    onSelected: (value) =>
                        setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: 'Практика',
                    value: 'practice',
                    groupValue: _selectedType,
                    onSelected: (value) =>
                        setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: 'Лабораторная',
                    value: 'lab',
                    groupValue: _selectedType,
                    onSelected: (value) =>
                        setState(() => _selectedType = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Время
              Row(
                children: [
                  Expanded(
                    child: _TimeSelector(
                      label: 'Начало',
                      time: _startTime,
                      onTimeSelected: (time) =>
                          setState(() => _startTime = time),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimeSelector(
                      label: 'Конец',
                      time: _endTime,
                      onTimeSelected: (time) => setState(() => _endTime = time),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Кнопка сохранения
              CustomButton(
                text: 'Добавить',
                onPressed: _saveLesson,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime.hour,
      _endTime.minute,
    );

    final lesson = LessonModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _subjectController.text,
      teacher: _teacherController.text,
      room: _roomController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      type: _selectedType,
      dayOfWeek: widget.selectedDay,
    );

    context.read<ScheduleProvider>().addLesson(lesson);

    final firestore = FirestoreService();
    await firestore.addLesson(lesson);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${lesson.subject} добавлен в расписание'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.white,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textGrey,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : AppColors.textGrey.withValues(alpha: 0.3),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedTime != null) {
              onTimeSelected(pickedTime);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textGrey.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ========== ОПЦИИ ЗАНЯТИЯ (ДЛЯ СТАРОСТЫ) ==========

class _LessonOptionsSheet extends StatelessWidget {
  final LessonModel lesson;

  const _LessonOptionsSheet({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded, color: AppColors.info),
            ),
            title: const Text('Редактировать'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔧 Функция в разработке')),
              );
            },
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_rounded, color: AppColors.error),
            ),
            title: const Text('Удалить'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить занятие?'),
        content: Text('Вы уверены, что хотите удалить "${lesson.subject}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              // ← делаем асинхронной
              context.read<ScheduleProvider>().deleteLesson(lesson.id);

              final firestore = FirestoreService();
              await firestore.deleteLesson(lesson.id);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ ${lesson.subject} удалён'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
