import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/theme.dart';
import 'data/providers.dart';

import 'firebase_options.dart';

import 'pages/register.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/schedule.dart';
import 'pages/ai_friend.dart';
import 'pages/calendar.dart';
import 'pages/expenses.dart';
import 'pages/notes.dart';
import 'pages/news.dart';
import 'pages/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('en_US', null);
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
      child: Builder(
        builder: (context) {
          final userProvider = context.read<UserProvider>();
          final router = _createRouter(userProvider);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            supportedLocales: const [Locale('en', 'US'), Locale('ru', 'RU')],
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

GoRouter _createRouter(UserProvider userProvider) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: userProvider,
    redirect: (context, state) {
      final bool loggedIn = userProvider.isAuthenticated;
      final bool isRegisterRoute = state.matchedLocation == '/register' || state.matchedLocation == '/login';
      if (!loggedIn) return isRegisterRoute ? null : '/register';
      if (loggedIn && isRegisterRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            if (userProvider.isAuthenticated && userProvider.user == null) {
              userProvider.fetchUserData();
            }
            return HomeScreen(navigationShell: navigationShell);
          },
          branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', name: 'home', builder: (_, _) => const HomeTab()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/expenses', name: 'expenses', builder: (_, _) => const ExpensesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/notes', name: 'notes', builder: (_, _) => const NotesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/calendar', name: 'calendar', builder: (_, _) => const CalendarScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', name: 'profile', builder: (_, _) => const ProfileScreen()),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/schedule',
        name: 'schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/news',
        name: 'news',
        builder: (_, _) => const NewsScreen(),
      ),
      GoRoute(
        path: '/ai',
        name: 'ai',
        builder: (_, _) => const AIScreen(),
      ),
    ],
  );
}