class AppConstants {
  AppConstants._();

  static const Map<String, List<String>> collegesWithGroups = {
    'AITU': ['ПО2303', 'ПО2301', 'ПО2306'],
    'KILC': ['K-1', 'K-2', 'K-3'],
    'Turan': ['Т-1', 'Т-2', 'Т-3'],
    'Urban College': ['U-1', 'U-2', 'U-3'],
    'Astana Polytechnic': ['P-1', 'P-2', 'P-3'],
    'College of Service and Tourism': ['C-1', 'C-2', 'C-3'],
  };

  static List<String> get colleges => collegesWithGroups.keys.toList();

  static const List<Map<String, String>> expenseCategories = [
    {'id': 'transport', 'name': 'Transport', 'emoji': '🚌'},
    {'id': 'food', 'name': 'Food', 'emoji': '🍔'},
    {'id': 'books', 'name': 'Books', 'emoji': '📚'},
    {'id': 'housing', 'name': 'Housing', 'emoji': '🏠'},
    {'id': 'entertainment', 'name': 'Entertainment', 'emoji': '🎮'},
    {'id': 'health', 'name': 'Health', 'emoji': '💊'},
    {'id': 'clothing', 'name': 'Clothing', 'emoji': '👕'},
    {'id': 'communication', 'name': 'Communication', 'emoji': '📱'},
  ];

  static const List<Map<String, String>> newsCategories = [
    {'id': 'events', 'name': 'Events', 'emoji': '📢'},
    {'id': 'academic', 'name': 'Academic', 'emoji': '🎓'},
    {'id': 'sporting', 'name': 'Sporting', 'emoji': '🏀'},
  ];

  static const List<Map<String, String>> eventCategories = [
    {'id': 'academic', 'name': 'Academic', 'emoji': '📚'},
    {'id': 'deadline', 'name': 'Deadline', 'emoji': '⏰'},
    {'id': 'personal', 'name': 'Personal', 'emoji': '🎉'},
    {'id': 'news', 'name': 'News', 'emoji': '📢'},
  ];

  static const List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
}