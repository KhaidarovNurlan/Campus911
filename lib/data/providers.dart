import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';
import 'firestore_service.dart';
import 'ai_chat_provider.dart';

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
  final List<EventModel> _events = [];
  final _firestoreService = FirestoreService();

  DateTime _selectedDate = DateTime.now();

  List<EventModel> get events => _events;
  DateTime get selectedDate => _selectedDate;

  CalendarProvider() {
    loadEvents();
  }

  Future<void> loadEvents() async {
    final events = await _firestoreService.getAllEvents();
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
      photoUrl: null,
    ),
    TeacherModel(
      id: '2',
      name: 'Mr. Sintikov',
      subject: 'Arduino',
      rating: 5,
      reviewCount: 0,
      photoUrl: null,
    ),
    TeacherModel(
      id: '3',
      name: 'Алмас Айдарович',
      subject: 'Джава',
      rating: 5,
      reviewCount: 0,
      photoUrl: null,
    ),
  ];
  final Map<String, List<ReviewModel>> _reviews = {};

  List<TeacherModel> get teachers => _teachers;

  List<ReviewModel> getReviewsForTeacher(String teacherId) {
    return _reviews[teacherId] ?? [];
  }

  Future<void> loadData() async {
    // _teachers = await _firestore.getTeachers();
    final allReviews = await _firestore.getReviews();

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

class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ChangeNotifierProvider<ScheduleProvider>(create: (_) => ScheduleProvider()),
    ChangeNotifierProvider<AIChatProvider>(create: (_) => AIChatProvider()),
    ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
    ChangeNotifierProvider<NewsProvider>(create: (_) => NewsProvider()),
    ChangeNotifierProvider<CalendarProvider>(create: (_) => CalendarProvider()),
    ChangeNotifierProvider<ReviewProvider>(
      create: (_) => ReviewProvider()..loadData(),
    ),
  ];
}
