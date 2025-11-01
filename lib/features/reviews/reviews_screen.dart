import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

/// ⭐ Экран отзывов о преподавателях
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String _sortBy = 'rating'; // rating, reviews, name

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final teachers = _sortTeachers(reviewProvider.teachers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отзывы о преподавателях'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Сортировка',
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rating', child: Text('По рейтингу')),
              const PopupMenuItem(
                value: 'reviews',
                child: Text('По количеству отзывов'),
              ),
              const PopupMenuItem(value: 'name', child: Text('По имени')),
            ],
          ),
        ],
      ),
      body: teachers.isEmpty
          ? _EmptyTeachers()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                return _TeacherCard(teacher: teachers[index]);
              },
            ),
    );
  }

  List<TeacherModel> _sortTeachers(List<TeacherModel> teachers) {
    final sorted = List<TeacherModel>.from(teachers);

    switch (_sortBy) {
      case 'rating':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'reviews':
        sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return sorted;
  }
}

// ========== КАРТОЧКА ПРЕПОДАВАТЕЛЯ ==========

class _TeacherCard extends StatelessWidget {
  final TeacherModel teacher;

  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showTeacherDetails(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Аватар
                  _TeacherAvatar(name: teacher.name),
                  const SizedBox(width: 16),

                  // Информация
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          teacher.subject,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: _getRatingColor(teacher.rating),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              teacher.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getRatingColor(teacher.rating),
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${teacher.reviewCount} отзывов)',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Стрелка
                  Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                ],
              ),
              const SizedBox(height: 16),

              // Рейтинг бар
              _RatingBar(rating: teacher.rating),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return AppColors.success;
    if (rating >= 3.5) return AppColors.primary;
    if (rating >= 2.5) return AppColors.warning;
    return AppColors.error;
  }

  void _showTeacherDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TeacherDetailsScreen(teacher: teacher),
      ),
    );
  }
}

// Аватар преподавателя
class _TeacherAvatar extends StatelessWidget {
  final String name;

  const _TeacherAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.split(' ').first[0] + name.split(' ').last[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Визуальный рейтинг бар
class _RatingBar extends StatelessWidget {
  final double rating;

  const _RatingBar({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            starValue <= rating.round()
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: AppColors.warning,
            size: 24,
          ),
        );
      }),
    );
  }
}

// Пустой список
class _EmptyTeachers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 80,
              color: AppColors.textGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Нет преподавателей',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Список преподавателей пуст',
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

// ========== ДЕТАЛЬНАЯ СТРАНИЦА ПРЕПОДАВАТЕЛЯ ==========

class _TeacherDetailsScreen extends StatefulWidget {
  final TeacherModel teacher;

  const _TeacherDetailsScreen({required this.teacher});

  @override
  State<_TeacherDetailsScreen> createState() => _TeacherDetailsScreenState();
}

class _TeacherDetailsScreenState extends State<_TeacherDetailsScreen> {
  String _filterRating = 'all'; // all, 5, 4, 3, 2, 1

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final reviews = reviewProvider.getReviewsForTeacher(widget.teacher.id);
    final filteredReviews = _filterReviews(reviews);

    return Scaffold(
      appBar: AppBar(title: const Text('Отзывы')),
      body: Column(
        children: [
          // Заголовок с информацией
          _TeacherHeader(teacher: widget.teacher),

          // Фильтр по звёздам
          _StarFilter(
            selectedRating: _filterRating,
            onRatingChanged: (rating) => setState(() => _filterRating = rating),
          ),

          const Divider(height: 1),

          // Список отзывов
          Expanded(
            child: filteredReviews.isEmpty
                ? _EmptyReviews()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReviews.length,
                    itemBuilder: (context, index) {
                      return _ReviewCard(review: filteredReviews[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context),
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Оставить отзыв'),
      ),
    );
  }

  List<ReviewModel> _filterReviews(List<ReviewModel> reviews) {
    if (_filterRating == 'all') return reviews;

    final rating = int.parse(_filterRating);
    return reviews.where((r) => r.rating.round() == rating).toList();
  }

  void _showAddReviewDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddReviewBottomSheet(teacher: widget.teacher),
    );
  }
}

// Заголовок с преподавателем
class _TeacherHeader extends StatelessWidget {
  final TeacherModel teacher;

  const _TeacherHeader({required this.teacher});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
      ),
      child: Column(
        children: [
          _TeacherAvatar(name: teacher.name),
          const SizedBox(height: 16),
          Text(
            teacher.name,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            teacher.subject,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        teacher.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${teacher.reviewCount} отзывов',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Фильтр по звёздам
class _StarFilter extends StatelessWidget {
  final String selectedRating;
  final ValueChanged<String> onRatingChanged;

  const _StarFilter({
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Все',
              isSelected: selectedRating == 'all',
              onTap: () => onRatingChanged('all'),
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (index) {
              final rating = (5 - index).toString();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: '$rating ⭐',
                  isSelected: selectedRating == rating,
                  onTap: () => onRatingChanged(rating),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : AppColors.background),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textGrey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Карточка отзыва
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(
                    review.isAnonymous
                        ? Icons.person_outline_rounded
                        : Icons.person_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('d MMM yyyy', 'ru_RU').format(review.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: review.rating,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star_rounded, color: AppColors.warning),
                  itemCount: 5,
                  itemSize: 20,
                  direction: Axis.horizontal,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// Пустые отзывы
class _EmptyReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: AppColors.textGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.emptyReviewsMessage,
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

// ========== ДОБАВЛЕНИЕ ОТЗЫВА ==========

class _AddReviewBottomSheet extends StatefulWidget {
  final TeacherModel teacher;

  const _AddReviewBottomSheet({required this.teacher});

  @override
  State<_AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<_AddReviewBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  double _rating = 5.0;
  bool _isAnonymous = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.read<UserProvider>();

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
                      Icons.rate_review_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Оставить отзыв',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          widget.teacher.name,
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

              // Рейтинг
              Center(
                child: Column(
                  children: [
                    Text(
                      'Ваша оценка',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() => _rating = rating);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRatingText(_rating),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Комментарий
              CustomTextField(
                label: 'Комментарий',
                hint: 'Поделитесь своим мнением...',
                controller: _commentController,
                maxLines: 4,
                prefixIcon: const Icon(Icons.comment_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Напишите комментарий';
                  }
                  if (value.length < 10) {
                    return 'Минимум 10 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Анонимно
              SwitchListTile(
                value: _isAnonymous,
                onChanged: (value) => setState(() => _isAnonymous = value),
                title: const Text('Оставить анонимно'),
                subtitle: Text(
                  _isAnonymous
                      ? 'Ваше имя не будет показано'
                      : 'Отзыв будет от вашего имени',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                ),
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Кнопка отправки
              CustomButton(
                text: 'Отправить',
                onPressed: () => _submitReview(userProvider),
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Отлично!';
    if (rating >= 3.5) return 'Хорошо';
    if (rating >= 2.5) return 'Нормально';
    if (rating >= 1.5) return 'Плохо';
    return 'Ужасно';
  }

  void _submitReview(UserProvider userProvider) {
    if (!_formKey.currentState!.validate()) return;

    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teacherId: widget.teacher.id,
      studentName: userProvider.user?.name ?? 'Студент',
      rating: _rating,
      comment: _commentController.text,
      date: DateTime.now(),
      isAnonymous: _isAnonymous,
    );

    context.read<ReviewProvider>().addReview(review);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Отзыв успешно добавлен'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
