import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<NewsModel>> getNews(String college) async {
    final snapshot = await _db
        .collection('news')
        .where('college', isEqualTo: college)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return NewsModel(
        id: doc.id,
        title: data['title'],
        content: data['content'],
        category: data['category'],
        date: (data['date'] as Timestamp).toDate(),
        college: data['college'],
      );
    }).toList();
  }

  Future<void> addNews(NewsModel news) async {
    await _db.collection('news').add({
      'title': news.title,
      'content': news.content,
      'category': news.category,
      'date': news.date,
      'college': news.college,
    });
  }

  Future<void> deleteNews(String id) async {
    await _db.collection('news').doc(id).delete();
  }

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ExpenseModel(
        id: doc.id,
        amount: (data['amount'] as num).toDouble(),
        category: data['category'] ?? 'other',
        date: (data['date'] as Timestamp).toDate(),
        note: data['note'],
      );
    }).toList();
  }

  Future<void> addExpense(String userId, ExpenseModel expense) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expense.id)
        .set({
          'amount': expense.amount,
          'category': expense.category,
          'date': expense.date,
          'note': expense.note,
        });
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Future<List<LessonModel>> getLessons(String college, String groupName) async {
    final snapshot = await _db
        .collection('schedule')
        .where('college', isEqualTo: college)
        .where('groupName', isEqualTo: groupName)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return LessonModel(
        id: data['id'],
        subject: data['subject'],
        teacher: data['teacher'],
        room: data['room'],
        startTime: DateTime.parse(data['startTime']),
        endTime: DateTime.parse(data['endTime']),
        type: data['type'],
        dayOfWeek: data['dayOfWeek'],
        college: data['college'],
        groupName: data['groupName'],
      );
    }).toList();
  }

  Future<void> addLesson(LessonModel lesson) async {
    await _db.collection('schedule').doc(lesson.id).set({
      'id': lesson.id,
      'subject': lesson.subject,
      'teacher': lesson.teacher,
      'room': lesson.room,
      'startTime': lesson.startTime.toIso8601String(),
      'endTime': lesson.endTime.toIso8601String(),
      'type': lesson.type,
      'dayOfWeek': lesson.dayOfWeek,
      'college': lesson.college,
      'groupName': lesson.groupName,
    });
  }

  Future<void> deleteLesson(String id) async {
    await _db.collection('schedule').doc(id).delete();
  }

  Future<List<TeacherModel>> getTeachers(String college) async {
    final snapshot = await _db
        .collection('teachers')
        .where('college', isEqualTo: college)
        .get();
    return snapshot.docs
        .map((doc) => TeacherModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<ReviewModel>> getReviews(String college) async {
    final snapshot = await _db
        .collection('reviews')
        .where('college', isEqualTo: college)
        .get();
    return snapshot.docs
        .map((doc) => ReviewModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> addReview(ReviewModel review) async {
    await _db.collection('reviews').add(review.toMap());
  }

  Future<List<EventModel>> getEvents(String college) async {
    try {
      final snapshot = await _db
          .collection('events')
          .where('college', isEqualTo: college)
          .get();
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Ошибка загрузки событий: $e');
      return [];
    }
  }

  Future<void> addEvent(EventModel event) async {
    try {
      await _db.collection('events').doc(event.id).set(event.toMap());
    } catch (e) {
      debugPrint('Ошибка добавления события: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _db.collection('events').doc(id).delete();
    } catch (e) {
      debugPrint('Ошибка удаления события: $e');
    }
  }

  Future<List<String>> getGroupsByCollege(String college) async {
    final snapshot = await _db
        .collection('colleges')
        .doc(college)
        .collection('groups')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
