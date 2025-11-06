import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';
import '../../core/constants.dart';
import '../../theme/custom_button.dart';
import '../../theme/custom_text_field.dart';
import '../../data/providers.dart';

/// 💬 Список чатов
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userProvider = context.watch<UserProvider>();
    final isHeadman = userProvider.isHeadman;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔍 Поиск в разработке')),
              );
            },
          ),
        ],
      ),
      body: chatProvider.chats.isEmpty
          ? _EmptyChats(isHeadman: isHeadman)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chatProvider.chats.length,
              itemBuilder: (context, index) {
                return _ChatListItem(chat: chatProvider.chats[index]);
              },
            ),
      floatingActionButton: isHeadman
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateGroupDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Создать группу'),
            )
          : null,
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateGroupBottomSheet(),
    );
  }
}

// ========== ЭЛЕМЕНТ СПИСКА ЧАТОВ ==========

class _ChatListItem extends StatelessWidget {
  final dynamic chat;

  const _ChatListItem({required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/chat/${chat.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Аватар
            _ChatAvatar(name: chat.name),
            const SizedBox(width: 12),

            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д';
    } else {
      return DateFormat('dd.MM.yy').format(time);
    }
  }
}

// Аватар чата
class _ChatAvatar extends StatelessWidget {
  final String name;

  const _ChatAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Пустой список чатов
class _EmptyChats extends StatelessWidget {
  final bool isHeadman;

  const _EmptyChats({required this.isHeadman});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: AppColors.textGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.emptyChatsMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
            if (isHeadman) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Создать группу',
                onPressed: () => _showCreateGroupDialog(context),
                icon: Icons.add_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateGroupBottomSheet(),
    );
  }
}

// ========== СОЗДАНИЕ ГРУППЫ ==========

class _CreateGroupBottomSheet extends StatefulWidget {
  const _CreateGroupBottomSheet();

  @override
  State<_CreateGroupBottomSheet> createState() =>
      _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<_CreateGroupBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
                      Icons.group_add_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Создать группу',
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

              // Название группы
              CustomTextField(
                label: 'Название группы',
                hint: 'Группа 1А',
                controller: _nameController,
                prefixIcon: const Icon(Icons.group_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название группы';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Описание
              CustomTextField(
                label: 'Описание (опционально)',
                hint: 'О чём эта группа?',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.description_rounded),
              ),
              const SizedBox(height: 24),

              // Информация
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_rounded, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'После создания вы сможете пригласить участников',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Кнопка создания
              CustomButton(
                text: 'Создать',
                onPressed: _createGroup,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createGroup() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ChatProvider>().createGroup(
      _nameController.text,
      _descriptionController.text,
      ['1', '2', '3'], // Mock участники
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Группа "${_nameController.text}" создана'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
