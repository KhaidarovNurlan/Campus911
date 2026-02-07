import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/colors.dart';
import '../core/constants.dart';
import '../data/providers.dart';

class HomeScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Календарь'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_rounded), label: 'ИИ-друг'),
          BottomNavigationBarItem(icon: Icon(Icons.reviews_rounded), label: 'Отзывы'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Профиль'),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final scheduleProvider = context.watch<ScheduleProvider>();
    final newsProvider = context.watch<NewsProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final todayIndex = DateTime.now().weekday;
    final today = AppConstants.weekDays[todayIndex - 1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus911'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoading = true);
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoading
                  ? _ShimmerBox(width: 200, height: 32)
                  : Text(
                      'Привет, ${user?.name.split(' ').first ?? 'Студент'}! 👋',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
              const SizedBox(height: 24),

              _QuickActionsGrid(isLoading: _isLoading),
              const SizedBox(height: 24),

              _SectionHeader(
                title: 'Расписание на сегодня',
                icon: Icons.calendar_today_rounded,
                onTap: () => context.go('/schedule'),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              _TodaySchedule(
                lessons: scheduleProvider.getLessonsForDay(today),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              _SectionHeader(
                title: 'Последние новости',
                icon: Icons.newspaper_rounded,
                onTap: () => context.go('/news'),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              _NewsPreview(
                news: newsProvider.news.take(3).toList(),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              _SectionHeader(
                title: 'Расходы за месяц',
                icon: Icons.account_balance_wallet_rounded,
                onTap: () => context.go('/expenses'),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              _ExpensesSummary(
                totalAmount: expenseProvider.totalAmount,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/ai'),
        tooltip: 'AI-помощник',
        child: const Icon(Icons.smart_toy_rounded),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final bool isLoading;

  const _QuickActionsGrid({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 4,
        itemBuilder: (context, index) =>
            _ShimmerBox(width: double.infinity, height: double.infinity),
      );
    }

    final actions = [
      _QuickAction(
        icon: Icons.calendar_today_rounded,
        title: 'Расписание',
        color: AppColors.primary,
        onTap: () => context.go('/schedule'),
      ),
      _QuickAction(
        icon: Icons.newspaper_rounded,
        title: 'Новости',
        color: AppColors.info,
        onTap: () => context.go('/news'),
      ),
      _QuickAction(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Расходы',
        color: AppColors.warning,
        onTap: () => context.go('/expenses'),
      ),
      _QuickAction(
        icon: Icons.smart_toy_rounded,
        title: 'AI-помощник',
        color: AppColors.secondary,
        onTap: () => context.go('/ai'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _ShimmerBox(width: 200, height: 24);
    }

    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        TextButton(onPressed: onTap, child: const Text('Все')),
      ],
    );
  }
}

class _TodaySchedule extends StatelessWidget {
  final List lessons;
  final bool isLoading;

  const _TodaySchedule({required this.lessons, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ShimmerBox(width: double.infinity, height: 80),
          ),
        ),
      );
    }

    if (lessons.isEmpty) {
      return _EmptyState(
        icon: Icons.calendar_today_rounded,
        message: AppConstants.emptyScheduleMessage,
      );
    }

    return Column(
      children: lessons.take(2).map((lesson) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _LessonCard(lesson: lesson),
        );
      }).toList(),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final dynamic lesson;

  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.subject,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lesson.teacher} • Каб. ${lesson.room}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Text(
            lesson.timeRange,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsPreview extends StatelessWidget {
  final List news;
  final bool isLoading;

  const _NewsPreview({required this.news, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ShimmerBox(width: double.infinity, height: 80),
          ),
        ),
      );
    }

    if (news.isEmpty) {
      return _EmptyState(
        icon: Icons.newspaper_rounded,
        message: AppConstants.emptyNewsMessage,
      );
    }

    return Column(
      children: news.map((newsItem) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _NewsCard(newsItem: newsItem),
        );
      }).toList(),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final dynamic newsItem;

  const _NewsCard({required this.newsItem});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.go('/news'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  newsItem.categoryEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    newsItem.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              newsItem.content,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpensesSummary extends StatelessWidget {
  final double totalAmount;
  final bool isLoading;

  const _ExpensesSummary({required this.totalAmount, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _ShimmerBox(width: double.infinity, height: 80);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Всего потрачено',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalAmount.toStringAsFixed(0)} ₸',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textGrey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
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

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface : Colors.grey[300]!,
      highlightColor: isDark
          ? AppColors.textGrey.withValues(alpha: 0.1)
          : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}