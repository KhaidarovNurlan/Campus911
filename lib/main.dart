import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'app/theme/app_theme.dart';
import 'data/providers.dart';

// Экраны
import 'features/auth/auth_screen.dart';
import 'features/home/home_screen.dart';
import 'features/schedule/schedule_screen.dart';
import 'features/chat/chat_list_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/ai_chat/ai_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/expenses/expenses_screen.dart';
import 'features/reviews/reviews_screen.dart';
import 'features/news/news_screen.dart';
import 'features/attendance/attendance_screen.dart';
import 'features/profile/profile_screen.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ru_RU', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const Campus911App());
}

class Campus911App extends StatelessWidget {
  const Campus911App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Campus911',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

/// 🧭 Конфигурация маршрутов (GoRouter)
final GoRouter _router = GoRouter(
  initialLocation: '/auth',
  debugLogDiagnostics: true,

  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const _AuthWrapper(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/schedule',
      name: 'schedule',
      builder: (context, state) => const ScheduleScreen(),
    ),
    GoRoute(
      path: '/chats',
      name: 'chats',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      name: 'chat',
      builder: (context, state) {
        final chatId = state.pathParameters['id']!;
        return ChatScreen(chatId: chatId);
      },
    ),
    GoRoute(path: '/ai', name: 'ai', builder: (_, __) => const AIScreen()),
    GoRoute(
      path: '/calendar',
      name: 'calendar',
      builder: (_, __) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/expenses',
      name: 'expenses',
      builder: (_, __) => const ExpensesScreen(),
    ),
    GoRoute(
      path: '/reviews',
      name: 'reviews',
      builder: (_, __) => const ReviewsScreen(),
    ),
    GoRoute(
      path: '/news',
      name: 'news',
      builder: (_, __) => const NewsScreen(),
    ),
    GoRoute(
      path: '/attendance',
      name: 'attendance',
      builder: (_, __) => const AttendanceScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (_, __) => const ProfileScreen(),
    ),
  ],

  // Обработка 404
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '404: Страница не найдена',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('На главную'),
          ),
        ],
      ),
    ),
  ),
);

/// 🔐 Обертка — проверяет, вошел ли пользователь
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final userService = UserService();

          userService.fetchCurrentUser().then((userModel) {
            if (userModel != null) {
              context.read<UserProvider>().setUser(userModel);
            }
          });

          return const HomeScreen();
        }

        return const AuthScreen();
      },
    );
  }
}
