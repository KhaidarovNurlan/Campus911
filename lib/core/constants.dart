class AppConstants {
  AppConstants._();

  static const Map<String, List<String>> collegesWithGroups = {
    'AITU': ['ПО2303', 'ПО2301', 'ПО2306', 'ВТ2310'],
    'KILC': ['1-K-1', '1-K-2', '2-K-3'],
    'Turan': ['Т-101', 'Т-102', 'Т-201'],
    'Urban College': ['U-11', 'U-12', 'U-21'],
    'Astana Polytechnic': ['П-20-1', 'П-20-2', 'ВТ-20-3'],
    'Колледж сервиса и туризма': ['СТ-1', 'СТ-2', 'ГД-3'],
  };

  static List<String> get colleges => collegesWithGroups.keys.toList();

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

  static const List<String> weekDays = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static const String emptyScheduleMessage = 'Расписание на этот день пока не добавлено';
  static const String emptyNewsMessage = 'Новостей пока нет';
  static const String emptyReviewsMessage = 'Отзывов пока нет';
}