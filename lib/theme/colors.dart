import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00C853);
  static const Color primaryDark = Color(0xFF009624);
  static const Color primaryLight = Color(0xFF5EFC82);

  static const Color secondary = Color(0xFF757575);
  static const Color secondaryLight = Color(0xFFBDBDBD);
  static const Color secondaryDark = Color(0xFF424242);

  static const Color white = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFF5F5F5);

  static const Color textDark = Color(0xFF212121);

  static const Color textGrey = Color(0xFF757575);

  static const Color darkBackground = Color(0xFF121212);

  static const Color darkSurface = Color(0xFF1E1E1E);

  static const Color textLight = Color(0xFFE0E0E0);

  static const Color error = Color(0xFFD32F2F);

  static const Color warning = Color(0xFFFF9800);

  static const Color info = Color(0xFF2196F3);

  static const Color success = Color(0xFF4CAF50);

  static const Color divider = Color(0xFFE0E0E0);

  static Color shadow = Colors.black.withValues(alpha: 0.1);

  static Color shadowDark = Colors.black.withValues(alpha: 0.3);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkSurface, darkBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color academic = primary;

  static const Color deadline = error;

  static const Color personal = secondary;

  static const Color news = info;

  static const Color transport = Color(0xFF2196F3);

  static const Color food = Color(0xFFFF9800);

  static const Color books = Color(0xFF4CAF50);

  static const Color housing = Color(0xFF9C27B0);

  static const Color entertainment = Color(0xFFE91E63);

  static const Color health = Color(0xFFF44336);

  static const Color clothing = Color(0xFF00BCD4);

  static const Color communication = Color(0xFF3F51B5);
}
