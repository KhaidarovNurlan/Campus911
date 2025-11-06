import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'theme/theme.dart';
import 'data/providers.dart';

import 'firebase_options.dart';

import 'pages/auth.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/schedule.dart';
import 'pages/chat/chat_list_screen.dart';
import 'pages/chat/chat_screen.dart';
import 'pages/ai_chat/ai_screen.dart';
import 'pages/calendar/calendar_screen.dart';
import 'pages/expenses.dart';
import 'pages/reviews/reviews_screen.dart';
import 'pages/news.dart';
import 'pages/attendance/attendance_screen.dart';
import 'pages/profile.dart';
import 'data/user_service.dart';

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
            supportedLocales: const [Locale('en', 'US'), Locale('ru', 'RU')],
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
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
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
