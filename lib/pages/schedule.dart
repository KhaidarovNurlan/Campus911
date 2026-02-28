import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';
import '../theme/constants.dart';
import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';
import '../data/models.dart';
import '../data/providers.dart';

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
    _initData();
  }

  Future<void> _initData() async {
    await Future.microtask(() {
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      context.read<ScheduleProvider>().loadSchedule(
        userProvider.college,
        userProvider.groupName,
      );
    });
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
        title: const Text('Schedule'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          tabs: AppConstants.weekDays.map((day) {
            return Tab(text: day.substring(0, 2));
          }).toList(),
        ),
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
      floatingActionButton: isHeadman
          ? FloatingActionButton.extended(
              onPressed: () => _showAddLessonDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            )
          : null,
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

              Container(width: 1, height: 80, color: AppColors.divider),

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
                        text: 'Room ${lesson.room}',
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
              'Schedule for $day\nhas not been added yet',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddLessonBottomSheet extends StatefulWidget {
  final String selectedDay;
  final LessonModel? lessonToEdit;

  const _AddLessonBottomSheet({
    required this.selectedDay,
    this.lessonToEdit,
  });

  @override
  State<_AddLessonBottomSheet> createState() => _AddLessonBottomSheetState();
}

class _AddLessonBottomSheetState extends State<_AddLessonBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _teacherController;
  late TextEditingController _roomController;

  String _selectedType = 'lecture';
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.lessonToEdit?.subject ?? '');
    _teacherController = TextEditingController(text: widget.lessonToEdit?.teacher ?? '');
    _roomController = TextEditingController(text: widget.lessonToEdit?.room ?? '');

    _selectedType = widget.lessonToEdit?.type ?? 'lecture';

    if (widget.lessonToEdit != null) {
      _startTime = TimeOfDay.fromDateTime(widget.lessonToEdit!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.lessonToEdit!.endTime);
    } else {
      _startTime = const TimeOfDay(hour: 10, minute: 0);
      _endTime = const TimeOfDay(hour: 11, minute: 30);
    }
  }

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
    final isEditing = widget.lessonToEdit != null;

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
                        Text(isEditing ? 'Edit lesson' : 'Add a lesson', style: Theme.of(context).textTheme.headlineSmall),
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

              CustomTextField(
                label: 'Subject',
                hint: '...',
                controller: _subjectController,
                prefixIcon: const Icon(Icons.book_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the name of the subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Teacher',
                hint: '...',
                controller: _teacherController,
                prefixIcon: const Icon(Icons.person_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter the teacher's full name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Room',
                hint: '...',
                controller: _roomController,
                prefixIcon: const Icon(Icons.room_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the room number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Text(
                'Lesson type',
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
                    label: 'Lecture',
                    value: 'lecture',
                    groupValue: _selectedType,
                    onSelected: (value) =>
                        setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: 'Practice',
                    value: 'practice',
                    groupValue: _selectedType,
                    onSelected: (value) =>
                        setState(() => _selectedType = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _TimeSelector(
                      label: 'Start',
                      time: _startTime,
                      onTimeSelected: (time) =>
                          setState(() => _startTime = time),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimeSelector(
                      label: 'End',
                      time: _endTime,
                      onTimeSelected: (time) => setState(() => _endTime = time),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: isEditing ? 'Save Changes' : 'Add',
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
    final userProvider = context.read<UserProvider>();
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
      id: widget.lessonToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _subjectController.text,
      teacher: _teacherController.text,
      room: _roomController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      type: _selectedType,
      dayOfWeek: widget.selectedDay,
      college: userProvider.college,
      groupName: userProvider.groupName,
    );

    final provider = context.read<ScheduleProvider>();

    if (widget.lessonToEdit != null) {
      provider.updateLesson(lesson);
    } else {
      provider.addLesson(lesson);
    }

    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.lessonToEdit != null ? '✅ ${lesson.subject} updated' : '✅ ${lesson.subject} added'),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded, color: AppColors.info),
            ),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              _showEditLessonDialog(context);
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
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditLessonDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddLessonBottomSheet(
        selectedDay: lesson.dayOfWeek,
        lessonToEdit: lesson,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete lesson?'),
        content: Text('Are you sure you want to delete "${lesson.subject}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.read<ScheduleProvider>().deleteLesson(lesson.id);

              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ ${lesson.subject} deleted'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
