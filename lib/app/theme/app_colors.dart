import 'package:flutter/material.dart';

/// 🎨 Цветовая палитра Campus911 (строго 3 цвета + оттенки)
class AppColors {
  AppColors._();

  // ========== ОСНОВНЫЕ ЦВЕТА ==========

  /// 💚 Зелёный (Primary) - основной акцентный цвет
  static const Color primary = Color(0xFF00C853);
  static const Color primaryDark = Color(0xFF009624);
  static const Color primaryLight = Color(0xFF5EFC82);

  /// 🩶 Серый (Secondary) - вторичный цвет
  static const Color secondary = Color(0xFF757575);
  static const Color secondaryLight = Color(0xFFBDBDBD);
  static const Color secondaryDark = Color(0xFF424242);

  // ========== СВЕТЛАЯ ТЕМА ==========

  /// ⚪ Белый - основной фон светлой темы
  static const Color white = Color(0xFFFFFFFF);

  /// 🤍 Светло-серый фон
  static const Color background = Color(0xFFF5F5F5);

  /// ⬛ Тёмный текст (для светлой темы)
  static const Color textDark = Color(0xFF212121);

  /// 🩶 Серый текст (для подписей)
  static const Color textGrey = Color(0xFF757575);

  // ========== ТЁМНАЯ ТЕМА ==========

  /// ⚫ Чёрный - основной фон тёмной темы
  static const Color darkBackground = Color(0xFF121212);

  /// 🖤 Тёмно-серая поверхность (карточки, AppBar)
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// ⚪ Светлый текст (для тёмной темы)
  static const Color textLight = Color(0xFFE0E0E0);

  // ========== ДОПОЛНИТЕЛЬНЫЕ ЦВЕТА ==========

  /// 🔴 Красный (для ошибок, дедлайнов)
  static const Color error = Color(0xFFD32F2F);

  /// 🟠 Оранжевый (для предупреждений)
  static const Color warning = Color(0xFFFF9800);

  /// 🔵 Синий (для информации)
  static const Color info = Color(0xFF2196F3);

  /// ✅ Зелёный успех
  static const Color success = Color(0xFF4CAF50);

  // ========== UI ЭЛЕМЕНТЫ ==========

  /// Разделитель
  static const Color divider = Color(0xFFE0E0E0);

  /// Тень для светлой темы
  static Color shadow = Colors.black.withValues(alpha: 0.1);

  /// Тень для тёмной темы
  static Color shadowDark = Colors.black.withValues(alpha: 0.3);

  // ========== ГРАДИЕНТЫ ==========

  /// 💚 Зелёный градиент
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 🌑 Тёмный градиент
  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkSurface, darkBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ========== ЦВЕТА ПО КАТЕГОРИЯМ ==========

  /// 📚 Учебные события (зелёный)
  static const Color academic = primary;

  /// ⏰ Дедлайны (красный)
  static const Color deadline = error;

  /// 🎉 Личные события (серый)
  static const Color personal = secondary;

  /// 📢 Новости (синий)
  static const Color news = info;

  // ========== КАТЕГОРИИ РАСХОДОВ ==========

  /// 🚌 Транспорт
  static const Color transport = Color(0xFF2196F3);

  /// 🍔 Еда
  static const Color food = Color(0xFFFF9800);

  /// 📚 Книги
  static const Color books = Color(0xFF4CAF50);

  /// 🏠 Проживание
  static const Color housing = Color(0xFF9C27B0);

  /// 🎮 Развлечения
  static const Color entertainment = Color(0xFFE91E63);

  /// 💊 Здоровье
  static const Color health = Color(0xFFF44336);

  /// 👕 Одежда
  static const Color clothing = Color(0xFF00BCD4);

  /// 📱 Связь
  static const Color communication = Color(0xFF3F51B5);
}
