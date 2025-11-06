import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';
import '../core/mock_data.dart';
import 'firestore_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isHeadman => _user?.isHeadman ?? false;
  bool get isStudent => _user?.isStudent ?? false;
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) {
    if (_user == null) return;
    _user = UserModel(
      id: _user!.id,
      name: name ?? _user!.name,
      email: email ?? _user!.email,
      phone: phone ?? _user!.phone,
      college: _user!.college,
      gender: _user!.gender,
      role: _user!.role,
      photoUrl: photoUrl ?? _user!.photoUrl,
    );
    notifyListeners();
  }
}

class ScheduleProvider extends ChangeNotifier {
  final List<LessonModel> _lessons = [];
  String _selectedDay = 'Понедельник';
  List<LessonModel> get lessons => _lessons;
  String get selectedDay => _selectedDay;
  List<LessonModel> getLessonsForDay(String day) {
    return _lessons.where((lesson) => lesson.dayOfWeek == day).toList();
  }

  void clearLessons() {
    _lessons.clear();
    notifyListeners();
  }

  void setSelectedDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  void addLesson(LessonModel lesson) {
    _lessons.add(lesson);
    notifyListeners();
  }

  void updateLesson(String id, LessonModel updatedLesson) {
    final index = _lessons.indexWhere((lesson) => lesson.id == id);
    if (index != -1) {
      _lessons[index] = updatedLesson;
      notifyListeners();
    }
  }

  void deleteLesson(String id) {
    _lessons.removeWhere((lesson) => lesson.id == id);
    notifyListeners();
  }
}

class ChatProvider extends ChangeNotifier {
  final List<ChatModel> _chats = MockData.chats;
  final Map<String, List<MessageModel>> _messages = {};
  List<ChatModel> get chats => _chats;
  List<MessageModel> getMessagesForChat(String chatId) {
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = MockData.getMessagesForChat(chatId);
    }
    return _messages[chatId]!;
  }

  void sendMessage(String chatId, String text) {
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: '1',
      senderName: 'Вы',
      timestamp: DateTime.now(),
      isMe: true,
    );
    _messages[chatId]!.add(message);
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = ChatModel(
        id: _chats[chatIndex].id,
        name: _chats[chatIndex].name,
        avatarUrl: _chats[chatIndex].avatarUrl,
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        participants: _chats[chatIndex].participants,
      );
    }
    notifyListeners();
  }

  void createGroup(String name, String description, List<String> participants) {
    final newChat = ChatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      lastMessage: 'Группа создана',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      participants: participants,
    );
    _chats.insert(0, newChat);
    notifyListeners();
  }
}

class AIChatProvider extends ChangeNotifier {
  final List<MessageModel> _messages = [];
  bool _isTyping = false;
  List<MessageModel> get messages => _messages;
  bool get isTyping => _isTyping;
  void sendMessage(String text) {
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: '1',
      senderName: 'Вы',
      timestamp: DateTime.now(),
      isMe: true,
    );
    _messages.add(userMessage);
    notifyListeners();
    _isTyping = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      final botResponse = _generateBotResponse(text);
      final botMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: botResponse,
        senderId: 'bot',
        senderName: 'AI Помощник',
        timestamp: DateTime.now(),
        isMe: false,
      );
      _messages.add(botMessage);
      _isTyping = false;
      notifyListeners();
    });
  }

  String _generateBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    if (_containsAny(lowerMessage, [
      'привет',
      'здравствуй',
      'хай',
      'йо',
      'hello',
    ])) {
      return _randomFromList([
        'Привет! Чем помочь? 👋',
        'Сам такой 😎',
        'Я - существую (Cogito Ergo Sum) 🧠',
        'Йоу! Слушаю тебя 🎧',
        'Здарова, студент! Готов решать твои проблемы 🤓',
        'Приветствую! Я твой цифровой помощник 🤖',
        'Хай! Задавай вопрос, не стесняйся 💬',
        'Салют! Что надо узнать сегодня? 📚',
      ]);
    }
    if (_containsAny(lowerMessage, [
      'расписание',
      'когда',
      'пара',
      'урок',
      'занятие',
    ])) {
      return '''📅 Сегодня у тебя:
- Математика - 10:00 (каб. 305)
- Физика - 12:00 (каб. 201)
- Программирование - 14:00 (каб. 102)''';
    }
    if (_containsAny(lowerMessage, ['дедлайн', 'задание', 'сдать', 'срок'])) {
      return '''⏰ Ближайшие дедлайны:
- Курсовая по программированию - 25 октября
- Реферат по истории - 30 октября
- Лабораторная по физике - 22 октября''';
    }
    if (_containsAny(lowerMessage, ['новости', 'события', 'что нового'])) {
      return '''📰 Свежие новости AITU:
- День открытых дверей - 20 октября в 15:00
- Хакатон CodeFest - 25-27 октября
- Концерт студентов - 1 ноября''';
    }
    if (_containsAny(lowerMessage, [
      'расход',
      'потратил',
      'деньги',
      'бюджет',
    ])) {
      return '''💰 Твои расходы за октябрь:
- Транспорт: 15,000 ₸
- Еда: 45,000 ₸
- Книги: 8,000 ₸
- Всего: 68,000 ₸''';
    }
    if (_containsAny(lowerMessage, [
      'помощь',
      'что умеешь',
      'команды',
      'функции',
    ])) {
      return '''🤖 Я умею:
✅ Показывать расписание
✅ Напоминать о дедлайнах
✅ Следить за расходами
✅ Показывать новости
✅ Отвечать на вопросы

Просто спроси!''';
    }
    if (_containsAny(lowerMessage, ['как дела', 'как ты', 'что у тебя'])) {
      return _randomFromList([
        'Все отлично! У тебя как? 😊',
        'Работаю на благо студентов! А ты что? 💪',
        'Существую в облаке, жду твоих вопросов ☁️',
        'Занят обработкой данных. Тебе что нужно? 📊',
      ]);
    }
    if (_containsAny(lowerMessage, ['спасибо', 'благодарю', 'thanks'])) {
      return _randomFromList([
        'Не за что! Обращайся 😉',
        'Всегда пожалуйста! 🤝',
        'Рад помочь! Это моя работа 🤖',
        'Легко! Еще что-нибудь нужно? ✨',
      ]);
    }
    return _randomFromList([
      'Хм, не совсем понял. Попробуй по-другому 🤔',
      'Переформулируй вопрос, пожалуйста 🔄',
      'Не уверен, что понял. Уточни? 🧐',
      'Это за пределами моих компетенций... Спроси что-то другое 🤷',
    ]);
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _randomFromList(List<String> list) {
    return list[DateTime.now().millisecond % list.length];
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}

class ExpenseProvider with ChangeNotifier {
  final _firestore = FirestoreService();
  final List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;
  double get totalAmount => _expenses.fold(0, (sum, e) => sum + e.amount);
  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (var e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Future<void> loadExpenses(String userId) async {
    _expenses
      ..clear()
      ..addAll(await _firestore.getExpenses(userId));
    notifyListeners();
  }

  Future<void> addExpense(String userId, ExpenseModel expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _firestore.addExpense(userId, expense);
  }

  Future<void> deleteExpense(String userId, String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await _firestore.deleteExpense(userId, id);
  }
}

class NewsProvider extends ChangeNotifier {
  final List<NewsModel> _news = [];
  bool _isLoading = false;
  String? _selectedCategory;
  bool get isLoading => _isLoading;
  List<NewsModel> get news => _selectedCategory == null
      ? _news
      : _news.where((n) => n.category == _selectedCategory).toList();
  String? get selectedCategory => _selectedCategory;
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();
    final firestore = FirestoreService();
    final fetched = await firestore.getNews();
    _news
      ..clear()
      ..addAll(fetched);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNews(NewsModel news) async {
    final firestore = FirestoreService();
    await firestore.addNews(news);
    _news.insert(0, news);
    notifyListeners();
  }

  Future<void> deleteNews(String id) async {
    final firestore = FirestoreService();
    await firestore.deleteNews(id);
    _news.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}

class CalendarProvider extends ChangeNotifier {
  final List<EventModel> _events = MockData.events;
  DateTime _selectedDate = DateTime.now();
  List<EventModel> get events => _events;
  DateTime get selectedDate => _selectedDate;
  List<EventModel> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(String id) {
    _events.removeWhere((event) => event.id == id);
    notifyListeners();
  }
}

class ReviewProvider extends ChangeNotifier {
  final List<TeacherModel> _teachers = MockData.teachers;
  final Map<String, List<ReviewModel>> _reviews = {};
  List<TeacherModel> get teachers => _teachers;
  List<ReviewModel> getReviewsForTeacher(String teacherId) {
    if (!_reviews.containsKey(teacherId)) {
      _reviews[teacherId] = MockData.getReviewsForTeacher(teacherId);
    }
    return _reviews[teacherId]!;
  }

  void addReview(ReviewModel review) {
    if (!_reviews.containsKey(review.teacherId)) {
      _reviews[review.teacherId] = [];
    }
    _reviews[review.teacherId]!.insert(0, review);
    final teacherIndex = _teachers.indexWhere((t) => t.id == review.teacherId);
    if (teacherIndex != -1) {
      final allReviews = _reviews[review.teacherId]!;
      final avgRating =
          allReviews.fold<double>(0, (sum, r) => sum + r.rating) /
          allReviews.length;
      _teachers[teacherIndex] = TeacherModel(
        id: _teachers[teacherIndex].id,
        name: _teachers[teacherIndex].name,
        subject: _teachers[teacherIndex].subject,
        rating: avgRating,
        reviewCount: allReviews.length,
        photoUrl: _teachers[teacherIndex].photoUrl,
      );
    }
    notifyListeners();
  }
}

class AttendanceProvider extends ChangeNotifier {
  List<StudentAttendanceModel> _students = MockData.students;
  List<StudentAttendanceModel> get students => _students;
  int get presentCount => _students.where((s) => s.isPresent).length;
  int get absentCount => _students.where((s) => !s.isPresent).length;
  double get attendancePercentage =>
      _students.isEmpty ? 0 : (presentCount / _students.length) * 100;
  void toggleAttendance(String studentId) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      _students[index] = _students[index].copyWith(
        isPresent: !_students[index].isPresent,
      );
      notifyListeners();
    }
  }

  void markAllPresent() {
    _students = _students.map((s) => s.copyWith(isPresent: true)).toList();
    notifyListeners();
  }

  void clearAll() {
    _students = _students.map((s) => s.copyWith(isPresent: false)).toList();
    notifyListeners();
  }

  void saveAttendance() {
    notifyListeners();
  }
}

class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ChangeNotifierProvider<ScheduleProvider>(create: (_) => ScheduleProvider()),
    ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
    ChangeNotifierProvider<AIChatProvider>(create: (_) => AIChatProvider()),
    ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
    ChangeNotifierProvider<NewsProvider>(create: (_) => NewsProvider()),
    ChangeNotifierProvider<CalendarProvider>(create: (_) => CalendarProvider()),
    ChangeNotifierProvider<ReviewProvider>(create: (_) => ReviewProvider()),
    ChangeNotifierProvider<AttendanceProvider>(
      create: (_) => AttendanceProvider(),
    ),
  ];
}
