import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/theme.dart';
import 'data/providers.dart';

import 'firebase_options.dart';

import 'pages/auth.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/schedule.dart';
import 'pages/ai_friend.dart';
import 'pages/calendar.dart';
import 'pages/expenses.dart';
import 'pages/reviews.dart';
import 'pages/news.dart';
import 'pages/profile.dart';
import 'data/user_service.dart';

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
  initialLocation: '/home',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/auth' || state.matchedLocation == '/login';

    if (!loggedIn && !loggingIn) return '/auth';
    if (loggedIn && loggingIn) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        final userProvider = context.read<UserProvider>();
        if (userProvider.user == null && FirebaseAuth.instance.currentUser != null) {
          UserService().fetchCurrentUser().then((userModel) {
            if (userModel != null && context.mounted) {
              userProvider.setUser(userModel);
            }
          });
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
            GoRoute(path: '/calendar', name: 'calendar', builder: (_, _) => const CalendarScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/ai', name: 'ai', builder: (_, _) => const AIScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/reviews', name: 'reviews', builder: (_, _) => const ReviewsScreen()),
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
      path: '/expenses',
      name: 'expenses',
      builder: (_, _) => const ExpensesScreen(),
    ),
    GoRoute(
      path: '/news',
      name: 'news',
      builder: (_, _) => const NewsScreen(),
    ),
  ],
);