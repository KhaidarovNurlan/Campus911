// 🔧 Константы приложения

class AppConstants {
  AppConstants._();

  // ========== ОБЩИЕ ==========
  static const String appName = 'Campus911';
  static const String appVersion = '1.0.0';

  // ========== РАЗМЕРЫ ==========
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // ========== АНИМАЦИИ ==========
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // ========== УНИВЕРСИТЕТЫ ==========
  static const List<String> universities = [
    'AITU',
    'MNU',
    'SDU',
    'Nazarbayev University',
    'Казахстанско-Британский технический университет',
    'Евразийский национальный университет',
  ];

  // ========== ГЕНДЕРЫ ==========
  static const List<String> genders = [
    'Мужской',
    'Женский',
    'Другое',
    'Не указывать',
  ];

  // ========== ТИПЫ ЗАНЯТИЙ ==========
  static const List<String> lessonTypes = [
    'Лекция',
    'Практика',
    'Лабораторная',
  ];

  // ========== КАТЕГОРИИ РАСХОДОВ ==========
  static const List<Map<String, String>> expenseCategories = [
    {'id': 'transport', 'name': 'Транспорт', 'emoji': '🚌'},
    {'id': 'food', 'name': 'Еда', 'emoji': '🍔'},
    {'id': 'books', 'name': 'Книги', 'emoji': '📚'},
    {'id': 'housing', 'name': 'Проживание', 'emoji': '🏠'},
    {'id': 'entertainment', 'name': 'Развлечения', 'emoji': '🎮'},
    {'id': 'health', 'name': 'Здоровье', 'emoji': '💊'},
    {'id': 'clothing', 'name': 'Одежда', 'emoji': '👕'},
    {'id': 'communication', 'name': 'Связь', 'emoji': '📱'},
  ];

  // ========== КАТЕГОРИИ НОВОСТЕЙ ==========
  static const List<Map<String, String>> newsCategories = [
    {'id': 'academic', 'name': 'Академические', 'emoji': '🎓'},
    {'id': 'events', 'name': 'События', 'emoji': '🎉'},
    {'id': 'achievements', 'name': 'Достижения', 'emoji': '🏆'},
    {'id': 'announcements', 'name': 'Объявления', 'emoji': '📢'},
  ];

  // ========== ТИПЫ СОБЫТИЙ ==========
  static const List<Map<String, String>> eventTypes = [
    {'id': 'academic', 'name': 'Учебные', 'emoji': '📚'},
    {'id': 'deadline', 'name': 'Дедлайны', 'emoji': '⏰'},
    {'id': 'personal', 'name': 'Личные', 'emoji': '🎉'},
    {'id': 'news', 'name': 'Новости', 'emoji': '📢'},
  ];

  // ========== ВРЕМЯ НАПОМИНАНИЙ ==========
  static const List<Map<String, dynamic>> reminderTimes = [
    {'value': 60, 'label': 'За 1 час'},
    {'value': 30, 'label': 'За 30 минут'},
    {'value': 15, 'label': 'За 15 минут'},
  ];

  // ========== ДНИ НЕДЕЛИ ==========
  static const List<String> weekDays = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  // ========== ЗВУКИ УВЕДОМЛЕНИЙ ==========
  static const List<String> notificationSounds = [
    'По умолчанию',
    'Мелодичный',
    'Будильник',
    'Без звука',
  ];

  // ========== РЕГУЛЯРНЫЕ ВЫРАЖЕНИЯ ==========
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(r'^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$');

  // ========== ТЕКСТОВЫЕ КОНСТАНТЫ ==========
  static const String emptyScheduleMessage =
      'Расписание на этот день пока не добавлено';
  static const String emptyChatsMessage = 'У вас пока нет чатов';
  static const String emptyExpensesMessage = 'Вы еще не добавили расходы';
  static const String emptyNewsMessage = 'Новостей пока нет';
  static const String emptyReviewsMessage = 'Отзывов пока нет';

  // ========== AI BOT ТРИГГЕРЫ ==========
  static const Map<String, List<String>> aiBotTriggers = {
    'greeting': ['привет', 'здравствуй', 'хай', 'йо', 'hello', 'hi'],
    'schedule': ['расписание', 'когда', 'пара', 'урок', 'занятие'],
    'deadlines': ['дедлайн', 'задание', 'сдать', 'срок'],
    'news': ['новости', 'события', 'что нового'],
    'expenses': ['расход', 'потратил', 'деньги', 'бюджет'],
    'help': ['помощь', 'что умеешь', 'команды', 'функции'],
    'howAreYou': ['как дела', 'как ты', 'что у тебя'],
    'thanks': ['спасибо', 'благодарю', 'thanks'],
  };
}
