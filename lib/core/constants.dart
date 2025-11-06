class AppConstants {
  AppConstants._();

  static const String appName = 'Campus911';
  static const String appVersion = '1.0.0';

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  static const List<String> colleges = [
    'AITU',
    'KILC',
    'Turan',
    'Urban College',
    'Astana Polytechnic',
    'Колледж сервиса и туризма',
  ];

  static const List<String> genders = [
    'Мужской',
    'Женский',
    'Другое',
    'Не указывать',
  ];

  static const List<String> lessonTypes = [
    'Лекция',
    'Практика',
    'Лабораторная',
  ];

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

  static const List<Map<String, String>> newsCategories = [
    {'id': 'academic', 'name': 'Академические', 'emoji': '🎓'},
    {'id': 'events', 'name': 'События', 'emoji': '🎉'},
    {'id': 'achievements', 'name': 'Достижения', 'emoji': '🏆'},
    {'id': 'announcements', 'name': 'Объявления', 'emoji': '📢'},
  ];

  static const List<Map<String, String>> eventTypes = [
    {'id': 'academic', 'name': 'Учебные', 'emoji': '📚'},
    {'id': 'deadline', 'name': 'Дедлайны', 'emoji': '⏰'},
    {'id': 'personal', 'name': 'Личные', 'emoji': '🎉'},
    {'id': 'news', 'name': 'Новости', 'emoji': '📢'},
  ];

  static const List<Map<String, dynamic>> reminderTimes = [
    {'value': 60, 'label': 'За 1 час'},
    {'value': 30, 'label': 'За 30 минут'},
    {'value': 15, 'label': 'За 15 минут'},
  ];

  static const List<String> weekDays = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  static const List<String> notificationSounds = [
    'По умолчанию',
    'Мелодичный',
    'Будильник',
    'Без звука',
  ];

  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(r'^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$');

  static const String emptyScheduleMessage =
      'Расписание на этот день пока не добавлено';
  static const String emptyChatsMessage = 'У вас пока нет чатов';
  static const String emptyExpensesMessage = 'Вы еще не добавили расходы';
  static const String emptyNewsMessage = 'Новостей пока нет';
  static const String emptyReviewsMessage = 'Отзывов пока нет';

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
