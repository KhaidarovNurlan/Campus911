import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/providers.dart';

/// 👥 Экран контроля посещаемости (только для старосты)
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    // Проверка роли
    if (!userProvider.isHeadman) {
      return Scaffold(
        appBar: AppBar(title: const Text('Посещаемость')),
        body: _AccessDenied(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Посещаемость'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          tabs: const [
            Tab(text: 'Отметить'),
            Tab(text: 'Статистика'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_MarkAttendanceTab(), _StatisticsTab()],
      ),
    );
  }
}

// ========== ОТКАЗ В ДОСТУПЕ ==========

class _AccessDenied extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: AppColors.textGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Доступ запрещён',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Эта функция доступна только старостам',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ========== ВКЛАДКА ОТМЕТКИ ПОСЕЩАЕМОСТИ ==========

class _MarkAttendanceTab extends StatelessWidget {
  const _MarkAttendanceTab();

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();

    return Column(
      children: [
        // Информационная карточка
        _AttendanceInfoCard(
          presentCount: attendanceProvider.presentCount,
          absentCount: attendanceProvider.absentCount,
          percentage: attendanceProvider.attendancePercentage,
        ),

        // Кнопки действий
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => attendanceProvider.markAllPresent(),
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text('Отметить всех'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => attendanceProvider.clearAll(),
                  icon: const Icon(Icons.clear_all_rounded),
                  label: const Text('Снять все'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Список студентов
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: attendanceProvider.students.length,
            itemBuilder: (context, index) {
              final student = attendanceProvider.students[index];
              return _StudentCheckboxTile(student: student);
            },
          ),
        ),

        // Кнопка сохранения
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: 'Сохранить посещаемость',
            onPressed: () => _saveAttendance(context),
            icon: Icons.save_rounded,
          ),
        ),
      ],
    );
  }

  void _saveAttendance(BuildContext context) {
    context.read<AttendanceProvider>().saveAttendance();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Посещаемость сохранена',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat(
                      'd MMMM yyyy, HH:mm',
                      'ru_RU',
                    ).format(DateTime.now()),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Информационная карточка
class _AttendanceInfoCard extends StatelessWidget {
  final int presentCount;
  final int absentCount;
  final double percentage;

  const _AttendanceInfoCard({
    required this.presentCount,
    required this.absentCount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Посещаемость',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('d MMM', 'ru_RU').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Присутствуют',
                  value: '$presentCount',
                  color: Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.cancel_rounded,
                  label: 'Отсутствуют',
                  value: '$absentCount',
                  color: Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.pie_chart_rounded,
                  label: 'Процент',
                  value: '${percentage.toStringAsFixed(0)}%',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Чекбокс студента
class _StudentCheckboxTile extends StatelessWidget {
  final dynamic student;

  const _StudentCheckboxTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: student.isPresent
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.textGrey.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            if (student.isPresent)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: CheckboxListTile(
          value: student.isPresent,
          onChanged: (value) {
            context.read<AttendanceProvider>().toggleAttendance(student.id);
          },
          title: Text(
            student.name,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            student.isPresent ? 'Присутствует' : 'Отсутствует',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: student.isPresent ? AppColors.success : AppColors.textGrey,
            ),
          ),
          secondary: CircleAvatar(
            backgroundColor: student.isPresent
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.textGrey.withValues(alpha: 0.1),
            child: Text(
              student.name[0],
              style: TextStyle(
                color: student.isPresent
                    ? AppColors.primary
                    : AppColors.textGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          activeColor: AppColors.primary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ========== ВКЛАДКА СТАТИСТИКИ ==========

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();

    // Mock данные для графика (в реальном приложении были бы из БД)
    final Map<String, int> weeklyAttendance = {
      'Пн': 7,
      'Вт': 8,
      'Ср': 6,
      'Чт': 8,
      'Пт': 5,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // График посещаемости
          Text(
            'График посещаемости за неделю',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _AttendanceChart(data: weeklyAttendance),
          const SizedBox(height: 24),

          // Топ-3 студента
          Text(
            'Лучшая посещаемость',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _TopStudents(students: attendanceProvider.students.take(3).toList()),
          const SizedBox(height: 24),

          // Прогульщики
          Text(
            'Нужно обратить внимание 😅',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _BottomStudents(
            students: attendanceProvider.students.reversed.take(3).toList(),
          ),
        ],
      ),
    );
  }
}

// График посещаемости
class _AttendanceChart extends StatelessWidget {
  final Map<String, int> data;

  const _AttendanceChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final keys = data.keys.toList();
                  if (value.toInt() < keys.length) {
                    return Text(
                      keys[value.toInt()],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGrey,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textGrey.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value.toDouble(),
                  color: AppColors.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Топ студенты
class _TopStudents extends StatelessWidget {
  final List students;

  const _TopStudents({required this.students});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: students.asMap().entries.map((entry) {
        final index = entry.key;
        final student = entry.value;
        return _StudentRankCard(
          rank: index + 1,
          student: student,
          percentage: 95 - (index * 5), // Mock процент
          isTop: true,
        );
      }).toList(),
    );
  }
}

// Прогульщики
class _BottomStudents extends StatelessWidget {
  final List students;

  const _BottomStudents({required this.students});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: students.asMap().entries.map((entry) {
        final index = entry.key;
        final student = entry.value;
        return _StudentRankCard(
          rank: index + 1,
          student: student,
          percentage: 45 + (index * 5), // Mock процент
          isTop: false,
        );
      }).toList(),
    );
  }
}

class _StudentRankCard extends StatelessWidget {
  final int rank;
  final dynamic student;
  final int percentage;
  final bool isTop;

  const _StudentRankCard({
    required this.rank,
    required this.student,
    required this.percentage,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTop
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Медаль/Ранг
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isTop
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isTop ? _getMedal(rank) : '$rank',
                  style: TextStyle(
                    fontSize: isTop ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Имя и процент
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: AppColors.textGrey.withValues(
                            alpha: 0.2,
                          ),
                          color: isTop ? AppColors.primary : AppColors.error,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$percentage%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isTop ? AppColors.primary : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
