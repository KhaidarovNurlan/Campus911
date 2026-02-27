import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'models.dart';
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
  String get college => _user?.college ?? '';
  String get groupName => _user?.groupName ?? '';

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
    String? college,
    String? groupName,
  }) {
    if (_user == null) return;
    _user = UserModel(
      id: _user!.id,
      name: name ?? _user!.name,
      email: email ?? _user!.email,
      college: college ?? _user!.college,
      groupName: groupName ?? _user!.groupName,
      role: _user!.role,
    );
    notifyListeners();
  }
}

class ScheduleProvider extends ChangeNotifier {
  final _firestore = FirestoreService();
  final List<LessonModel> _lessons = [];
  String _selectedDay = 'Monday';
  bool _isLoading = false;

  List<LessonModel> get lessons => _lessons;
  String get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;

  Future<void> loadSchedule(String college, String groupName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _firestore.getLessons(college, groupName);
      _lessons.clear();
      _lessons.addAll(fetched);
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<LessonModel> getLessonsForDay(String day) {
    return _lessons.where((lesson) => lesson.dayOfWeek == day).toList();
  }

  void setSelectedDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> addLesson(LessonModel lesson) async {
    await _firestore.addLesson(lesson);
    _lessons.add(lesson);
    notifyListeners();
  }

  Future<void> updateLesson(LessonModel updatedLesson) async {
    await _firestore.updateLesson(updatedLesson);
    final index = _lessons.indexWhere((l) => l.id == updatedLesson.id);
    if (index != -1) {
      _lessons[index] = updatedLesson;
      notifyListeners();
    }
  }

  Future<void> deleteLesson(String id) async {
    await _firestore.deleteLesson(id);
    _lessons.removeWhere((lesson) => lesson.id == id);
    notifyListeners();
  }

  void clearLessons() {
    _lessons.clear();
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

  Future<void> loadNews(String college) async {
    _isLoading = true;
    notifyListeners();
    final firestore = FirestoreService();
    final fetched = await firestore.getNews(college);
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
  final List<EventModel> _events = [];
  final _firestoreService = FirestoreService();

  DateTime _selectedDate = DateTime.now();

  List<EventModel> get events => _events;
  DateTime get selectedDate => _selectedDate;

  Future<void> loadEvents(String college) async {
    final events = await _firestoreService.getEvents(college);
    _events
      ..clear()
      ..addAll(events);
    notifyListeners();
  }

  Future<void> addEvent(EventModel event) async {
    await _firestoreService.addEvent(event);
    _events.add(event);
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    await _firestoreService.deleteEvent(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<EventModel> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }
}

class ReviewProvider extends ChangeNotifier {
  final _firestore = FirestoreService();

  final List<TeacherModel> _teachers = [
    TeacherModel(
      id: '1',
      name: 'Арсен Тимурович',
      subject: 'Мобилка',
      rating: 5,
      reviewCount: 0,
    ),
    TeacherModel(
      id: '2',
      name: 'Мистер Синтиков',
      subject: 'Ардуино',
      rating: 5,
      reviewCount: 0,
    ),
    TeacherModel(
      id: '3',
      name: 'Алмас Айдарович',
      subject: 'Джава',
      rating: 5,
      reviewCount: 0,
    ),
  ];
  final Map<String, List<ReviewModel>> _reviews = {};

  List<TeacherModel> get teachers => _teachers;

  List<ReviewModel> getReviewsForTeacher(String teacherId) {
    return _reviews[teacherId] ?? [];
  }

  Future<void> loadData(String college) async {
    final allReviews = await _firestore.getReviews(college);

    _reviews.clear();
    for (final review in allReviews) {
      _reviews.putIfAbsent(review.teacherId, () => []).add(review);
    }

    for (var i = 0; i < _teachers.length; i++) {
      final teacher = _teachers[i];
      final teacherReviews = _reviews[teacher.id] ?? [];
      if (teacherReviews.isNotEmpty) {
        final avg =
            teacherReviews.map((r) => r.rating).reduce((a, b) => a + b) /
            teacherReviews.length;
        _teachers[i] = teacher.copyWith(
          rating: avg,
          reviewCount: teacherReviews.length,
        );
      }
    }

    notifyListeners();
  }

  Future<void> addReview(ReviewModel review) async {
    await _firestore.addReview(review);

    _reviews.putIfAbsent(review.teacherId, () => []).insert(0, review);
    final teacherIndex = _teachers.indexWhere((t) => t.id == review.teacherId);
    if (teacherIndex != -1) {
      final allReviews = _reviews[review.teacherId]!;
      final avgRating =
          allReviews.fold<double>(0, (sum, r) => sum + r.rating) /
          allReviews.length;
      _teachers[teacherIndex] = _teachers[teacherIndex].copyWith(
        rating: avgRating,
        reviewCount: allReviews.length,
      );
    }

    notifyListeners();
  }
}

class ChatProvider extends ChangeNotifier {
  final List<MessageModel> _messages = [];
  final FirestoreService _firestore = FirestoreService();
  bool isTyping = false;
  ChatSession? _chatSession;
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  );

  List<MessageModel> get messages => _messages;

  Future<void> loadChatHistory(String userId) async {
    final history = await _firestore.getMessages(userId);
    _messages.clear();
    _messages.addAll(history);
    _chatSession = null;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String text,
    required String userId,
    required String userName,
  }) async {
    if (text.trim().isEmpty) return;

    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: userId,
      senderName: userName,
      timestamp: DateTime.now(),
      isMe: true,
    );

    _messages.add(userMsg);
    notifyListeners();
    await _firestore.saveMessage(userId, userMsg);

    isTyping = true;
    notifyListeners();

    try {
      _chatSession ??= _model.startChat(
        history: _messages.map((m) => Content(
          m.isMe ? 'user' : 'model',
          [TextPart(m.text)]
        )).toList(),
      );

      final response = await _chatSession!.sendMessage(Content.text(text));
      final botText = response.text ?? '...';

      final botMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: botText,
        senderId: 'bot',
        senderName: 'AI-friend',
        timestamp: DateTime.now(),
        isMe: false,
      );

      _messages.add(botMsg);
      await _firestore.saveMessage(userId, botMsg);
    } catch (e) {
      debugPrint("AI Chat Error: $e");
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  Future<void> clearChatHistory(String userId) async {
    await _firestore.clearChatHistory(userId);
    _messages.clear();
    _chatSession = null;
    notifyListeners();
  }
}

class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ChangeNotifierProvider<ScheduleProvider>(create: (_) => ScheduleProvider()),
    ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
    ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
    ChangeNotifierProvider<NewsProvider>(create: (_) => NewsProvider()),
    ChangeNotifierProvider<CalendarProvider>(create: (_) => CalendarProvider()),
    ChangeNotifierProvider<ReviewProvider>(create: (_) => ReviewProvider()),
  ];
}
