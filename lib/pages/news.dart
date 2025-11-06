import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';
import '../core/constants.dart';
import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';
import '../data/models.dart';
import '../data/providers.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final newsProvider = context.read<NewsProvider>();
      await newsProvider.loadNews();
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final userProvider = context.watch<UserProvider>();
    final isHeadman = userProvider.isHeadman;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Новости'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Фильтр',
            onSelected: (category) {
              newsProvider.setCategory(category == 'all' ? null : category);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded),
                    SizedBox(width: 12),
                    Text('Все'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...AppConstants.newsCategories.map((category) {
                return PopupMenuItem(
                  value: category['id'],
                  child: Row(
                    children: [
                      Text(category['emoji']!),
                      const SizedBox(width: 12),
                      Text(category['name']!),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: newsProvider.news.isEmpty
          ? _EmptyNews(isHeadman: isHeadman)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: newsProvider.news.length,
              itemBuilder: (context, index) {
                return _NewsCard(news: newsProvider.news[index]);
              },
            ),
      floatingActionButton: isHeadman
          ? FloatingActionButton.extended(
              onPressed: () => _showAddNewsDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить'),
            )
          : null,
    );
  }

  void _showAddNewsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddNewsBottomSheet(),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showNewsDetails(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.imageUrl == null)
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(news.category),
                        _getCategoryColor(news.category).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      news.categoryEmoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              news.category,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(news.categoryEmoji),
                              const SizedBox(width: 6),
                              Text(
                                news.categoryName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getCategoryColor(news.category),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(news.date),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      news.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      news.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Text(
                          'Читать далее',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'academic':
        return AppColors.primary;
      case 'events':
        return AppColors.info;
      case 'achievements':
        return AppColors.warning;
      case 'announcements':
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      return DateFormat('d MMM', 'ru_RU').format(date);
    }
  }

  void _showNewsDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewsDetailsSheet(news: news),
    );
  }
}

class _NewsDetailsSheet extends StatelessWidget {
  final NewsModel news;

  const _NewsDetailsSheet({required this.news});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            news.category,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              news.categoryEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              news.categoryName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _getCategoryColor(news.category),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        news.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat(
                              'd MMMM yyyy, HH:mm',
                              'ru_RU',
                            ).format(news.date),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(
                        news.content,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'academic':
        return AppColors.primary;
      case 'events':
        return AppColors.info;
      case 'achievements':
        return AppColors.warning;
      case 'announcements':
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }
}

class _EmptyNews extends StatelessWidget {
  final bool isHeadman;

  const _EmptyNews({required this.isHeadman});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_rounded,
              size: 80,
              color: AppColors.textGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.emptyNewsMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
            if (isHeadman) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Добавить новость',
                onPressed: () => _showAddNewsDialog(context),
                icon: Icons.add_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddNewsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddNewsBottomSheet(),
    );
  }
}

class _AddNewsBottomSheet extends StatefulWidget {
  const _AddNewsBottomSheet();

  @override
  State<_AddNewsBottomSheet> createState() => _AddNewsBottomSheetState();
}

class _AddNewsBottomSheetState extends State<_AddNewsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = 'announcements';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.article_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Добавить новость',
                      style: Theme.of(context).textTheme.headlineSmall,
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
                label: 'Заголовок',
                hint: 'День открытых дверей',
                controller: _titleController,
                prefixIcon: const Icon(Icons.title_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите заголовок';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Текст новости',
                hint: 'Расскажите подробнее...',
                controller: _contentController,
                maxLines: 5,
                prefixIcon: const Icon(Icons.article_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите текст новости';
                  }
                  if (value.length < 20) {
                    return 'Минимум 20 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Text(
                'Категория',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.newsCategories.map((category) {
                  final isSelected = _selectedCategory == category['id'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category['emoji']!),
                        const SizedBox(width: 6),
                        Text(category['name']!),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category['id']!);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundColor: isDark
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
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Опубликовать',
                onPressed: () => _publishNews(userProvider),
                icon: Icons.publish_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _publishNews(UserProvider userProvider) {
    if (!_formKey.currentState!.validate()) return;

    final news = NewsModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      category: _selectedCategory,
      date: DateTime.now(),
      college: userProvider.user?.college ?? 'AITU',
    );

    context.read<NewsProvider>().addNews(news);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Новость успешно опубликована'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
