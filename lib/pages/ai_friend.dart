import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/colors.dart';
import '../data/providers.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final user = context.read<UserProvider>().user;
      if (user != null) {
        await context.read<ChatProvider>().loadChatHistory(user.id);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: Row(
          children: [
            _BotAvatar(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verta',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Always in touch 🟢',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear history',
            onPressed: user == null
                ? null
                : () => _showClearConfirmation(context, chatProvider, user.id),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _EmptyAIChat(
                    userName: user?.name.split(' ')[1] ?? 'student',
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      return _AIMessageBubble(
                        message: chatProvider.messages[index],
                      );
                    },
                  ),
          ),

          if (chatProvider.isTyping) _TypingIndicator(),

          _AIMessageInput(
            controller: _messageController,
            onSend: () => _handleSend(chatProvider, userProvider),
          ),
        ],
      ),
    );
  }

  void _handleSend(ChatProvider chatProvider, UserProvider userProvider) {
    final user = userProvider.user;
    if (user == null || _messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    chatProvider.sendMessage(
      text: text,
      userId: user.id,
      userName: user.name,
    );

    _scrollToBottom();
  }

  void _showClearConfirmation(BuildContext context, ChatProvider chatProvider, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All messages will be deleted permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await chatProvider.clearChatHistory(userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ History cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  final double size;

  const _BotAvatar({this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/ai_bot.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AIMessageBubble extends StatelessWidget {
  final dynamic message;

  const _AIMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[_BotAvatar(size: 36), const SizedBox(width: 12)],
          Flexible(
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isMe
                            ? AppColors.primary
                            : AppColors.darkSurface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: isMe
                              ? const Radius.circular(20)
                              : const Radius.circular(4),
                          bottomRight: isMe
                              ? const Radius.circular(4)
                              : const Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : null,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('HH:mm').format(message.timestamp),
                            style: TextStyle(
                              color: isMe ? Colors.white70 : AppColors.textGrey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 300.ms),
          if (isMe) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _BotAvatar(size: 36),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 150),
                const SizedBox(width: 4),
                _TypingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.textGrey,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeOut(
          delay: Duration(milliseconds: delay),
          duration: 600.ms,
        )
        .then()
        .fadeIn(duration: 600.ms);
  }
}

class _EmptyAIChat extends StatelessWidget {
  final String userName;

  const _EmptyAIChat({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BotAvatar(size: 100)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),
            const SizedBox(height: 24),
            Text(
                  'Hi, $userName! 👋',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 200.ms),
            const SizedBox(height: 12),
            Text(
                  'I am your AI-friend. You can ask me anything you need!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _AIMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _AIMessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Tell me about...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),

            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return IconButton(
                  icon: Icon(
                    value.text.trim().isEmpty
                        ? Icons.send_rounded
                        : Icons.send_rounded,
                  ),
                  color: value.text.trim().isEmpty
                      ? AppColors.textGrey
                      : AppColors.primary,
                  onPressed: value.text.trim().isEmpty ? null : onSend,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
