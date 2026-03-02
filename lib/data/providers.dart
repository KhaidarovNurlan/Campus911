import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'models.dart';
import 'firebase_service.dart';

class UserProvider extends ChangeNotifier {
  final _firebase = FirebaseService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _firebase.isFirebaseLoggedIn;
  bool get isLoading => _isLoading;
  bool get isHeadman => _user?.isHeadman ?? false;
  bool get isStudent => _user?.isStudent ?? false;
  String get college => _user?.college ?? '';
  String get groupName => _user?.groupName ?? '';

  Future<UserModel?> fetchUserData() async {
    _user = await _firebase.fetchCurrentUser();
    notifyListeners();
    return _user;
  }

  Future<bool> checkGroupHeadman(String college, String group) async {
    return await _firebase.isHeadmanTaken(college, group);
  }

  Future<void> authorize({
    required String email,
    required String password,
    required String name,
    required String college,
    required String group,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebase.authorizeUser(
        email: email,
        password: password,
        name: name,
        college: college,
        group: group,
        role: role,
      );

      final currentUser = _firebase.currentUid;
      if (currentUser != null) {
        await fetchUserData();
      }
    } catch (e) {
      debugPrint("❌ Register Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final firebaseUser = await _firebase.signIn(email, password);
      if (firebaseUser != null) {
        final userData = await _firebase.fetchCurrentUser();
        if (userData != null) {
          _user = userData;
        }
      }
    } catch (e) {
      debugPrint("❌ Login Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _firebase.signOut();
    _user = null;
    notifyListeners();
  }

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}

class ScheduleProvider extends ChangeNotifier {
  final _firebase = FirebaseService();
  final List<LessonModel> _lessons = [];

  List<LessonModel> get lessons => _lessons;

  Future<void> loadSchedule(String college, String groupName) async {
    _lessons
      ..clear()
      ..addAll(await _firebase.getLessons(college, groupName));
    notifyListeners();
  }

  List<LessonModel> getLessonsForDay(String day) {
    return _lessons.where((lesson) => lesson.dayOfWeek == day).toList();
  }

  Future<void> addLesson(LessonModel lesson) async {
    await _firebase.addLesson(lesson);
    _lessons.add(lesson);
    notifyListeners();
  }

  Future<void> updateLesson(LessonModel updatedLesson) async {
    await _firebase.updateLesson(updatedLesson);
    final index = _lessons.indexWhere((l) => l.id == updatedLesson.id);
    if (index != -1) {
      _lessons[index] = updatedLesson;
      notifyListeners();
    }
  }

  Future<void> deleteLesson(String id) async {
    await _firebase.deleteLesson(id);
    _lessons.removeWhere((lesson) => lesson.id == id);
    notifyListeners();
  }
}

class NewsProvider extends ChangeNotifier {
  final _firebase = FirebaseService();
  final List<NewsModel> _news = [];
  String? _selectedCategory;

  String? get selectedCategory => _selectedCategory;
  List<NewsModel> get news {
    if (_selectedCategory == null) return _news;
    return _news.where((n) => n.category == _selectedCategory).toList();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadNews(String college) async {
    _news
      ..clear()
      ..addAll(await _firebase.getNews(college));
    notifyListeners();
  }

  Future<void> addNews(NewsModel news) async {
    await _firebase.addNews(news);
    _news.insert(0, news);
    notifyListeners();
  }

  Future<void> deleteNews(String id) async {
    await _firebase.deleteNews(id);
    _news.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}

class ChatProvider extends ChangeNotifier {
  final _firebase = FirebaseService();
  final List<MessageModel> _messages = [];
  ChatSession? _chatSession;
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  );
  bool isTyping = false;

  List<MessageModel> get messages => _messages;

  Future<void> loadChatHistory(String userId) async {
    _messages
      ..clear()
      ..addAll(await _firebase.getMessages(userId));
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

    await _firebase.saveMessage(userId, userMsg);
    _messages.add(userMsg);
    notifyListeners();

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
      await _firebase.saveMessage(userId, botMsg);
    } catch (e) {
      debugPrint("❌ Chat Error: $e");
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  Future<void> clearChatHistory(String userId) async {
    await _firebase.deleteMessages(userId);
    _messages.clear();
    _chatSession = null;
    notifyListeners();
  }
}

class ExpenseProvider with ChangeNotifier {
  final _firebase = FirebaseService();
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
      ..addAll(await _firebase.getExpenses(userId));
    notifyListeners();
  }

  Future<void> addExpense(String userId, ExpenseModel expense) async {
    await _firebase.addExpense(userId, expense);
    _expenses.add(expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String userId, String id) async {
    await _firebase.deleteExpense(userId, id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

class NotesProvider extends ChangeNotifier {
  final _firebase = FirebaseService();
  final List<NoteModel> _notes = [];

  List<NoteModel> get notes => _notes;

  Future<void> loadNotes(String userId) async {
    final fetchedNotes = await _firebase.getNotes(userId);
    _notes.clear();
    _notes.addAll(fetchedNotes);
    notifyListeners();
  }

  Future<void> addNote(String userId, NoteModel note) async {
    await _firebase.addNote(userId, note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> updateNote(String userId, NoteModel updatedNote) async {
    await _firebase.updateNote(userId, updatedNote);
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _firebase.deleteNote(userId, noteId);
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();
  }
}

class CalendarProvider extends ChangeNotifier {
  final _firebase = FirebaseService();
  final List<EventModel> _events = [];

  List<EventModel> get events => _events;

  Future<void> loadEvents(String college) async {
    _events
      ..clear()
      ..addAll(await _firebase.getEvents(college));
    notifyListeners();
  }

  List<EventModel> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  Future<void> addEvent(String userId, EventModel event) async {
    await _firebase.addEvent(userId, event);
    _events.add(event);
    notifyListeners();
  }

  Future<void> deleteEvent(String userId, String id) async {
    await _firebase.deleteEvent(userId, id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ChangeNotifierProvider<ScheduleProvider>(create: (_) => ScheduleProvider()),
    ChangeNotifierProvider<NewsProvider>(create: (_) => NewsProvider()),
    ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
    ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
    ChangeNotifierProvider<NotesProvider>(create: (_) => NotesProvider()),
    ChangeNotifierProvider<CalendarProvider>(create: (_) => CalendarProvider()),
  ];
}
