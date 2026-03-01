import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool get isFirebaseLoggedIn => FirebaseAuth.instance.currentUser != null;

  // ========== AUTHENTICATION ==========

  Future<UserModel?> fetchCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      return null;
    }
  }

  Future<bool> isHeadmanTaken(String college, String group) async {
    final snapshot = await _db
        .collection('users')
        .where('college', isEqualTo: college)
        .where('groupName', isEqualTo: group)
        .where('role', isEqualTo: 'headman')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> authorizeUser({
    required String email,
    required String password,
    required String name,
    required String college,
    required String group,
    required String role,
  }) async {
    if (role == 'headman') {
      final taken = await isHeadmanTaken(college, group);
      if (taken) throw Exception('Role "Headman" is already taken in this group');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        college: college,
        groupName: group,
        role: role,
      );

      await _db.collection('users').doc(user.id).set(user.toMap());
    }
  }

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get currentUid => _auth.currentUser?.uid;

  // ========== LESSONS ==========

  Future<List<LessonModel>> getLessons(String college, String groupName) async {
    final snapshot = await _db
        .collection('schedule')
        .where('college', isEqualTo: college)
        .where('groupName', isEqualTo: groupName)
        .withConverter<LessonModel>(
          fromFirestore: (doc, _) => LessonModel.fromMap(doc.data()!, doc.id),
          toFirestore: (lesson, _) => lesson.toMap(),
        )
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addLesson(LessonModel lesson) async {
    await _db.collection('schedule').doc(lesson.id).set(lesson.toMap());
  }

  Future<void> updateLesson(LessonModel lesson) async {
    await _db.collection('schedule').doc(lesson.id).update(lesson.toMap());
  }

  Future<void> deleteLesson(String id) async {
    await _db.collection('schedule').doc(id).delete();
  }

  // ========== NEWS ==========

  Future<List<NewsModel>> getNews(String college) async {
    final snapshot = await _db
        .collection('news')
        .where('college', isEqualTo: college)
        .orderBy('date', descending: true)
        .withConverter<NewsModel>(
          fromFirestore: (doc, _) => NewsModel.fromMap(doc.data()!, doc.id),
          toFirestore: (news, _) => news.toMap(),
        )
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addNews(NewsModel news) async {
    await _db.collection('news').doc(news.id).set(news.toMap());
  }

  Future<void> deleteNews(String id) async {
    await _db.collection('news').doc(id).delete();
  }

  // ========== MESSAGES ==========

  Future<List<MessageModel>> getMessages(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('ai_chats')
        .orderBy('timestamp')
        .withConverter<MessageModel>(
          fromFirestore: (doc, _) => MessageModel.fromMap(doc.data()!, doc.id),
          toFirestore: (message, _) => message.toMap(),
        )
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> saveMessage(String userId, MessageModel message) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('ai_chats')
        .doc(message.id)
        .set(message.toMap());
  }

  Future<void> deleteMessages(String userId) async {
    final ref = _db.collection('users').doc(userId).collection('ai_chats');
    final snapshot = await ref.get();
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ========== EXPENSES ==========

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .withConverter<ExpenseModel>(
          fromFirestore: (doc, _) => ExpenseModel.fromMap(doc.data()!, doc.id),
          toFirestore: (expense, _) => expense.toMap(),
        )
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addExpense(String userId, ExpenseModel expense) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // ========== NOTES ==========

  Future<List<NoteModel>> getNotes(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .withConverter<NoteModel>(
          fromFirestore: (doc, _) => NoteModel.fromMap(doc.data()!, doc.id),
          toFirestore: (note, _) => note.toMap(),
        )
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addNote(String userId, NoteModel note) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(note.id)
        .set(note.toMap());
  }

  Future<void> updateNote(String userId, NoteModel note) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  // ========== EVENTS ==========

  Future<List<EventModel>> getEvents(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .withConverter<EventModel>(
          fromFirestore: (doc, _) => EventModel.fromMap(doc.data()!, doc.id),
          toFirestore: (event, _) => event.toMap(),
        )
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addEvent(String userId, EventModel event) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(event.id.isEmpty ? null : event.id)
        .set(event.toMap());
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .delete();
  }
}
