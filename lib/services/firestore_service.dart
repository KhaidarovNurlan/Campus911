import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Сохранить занятие
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
    });
  }

  /// Загрузить все занятия
  Future<List<LessonModel>> getLessons() async {
    final snapshot = await _db.collection('schedule').get();
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
      );
    }).toList();
  }

  /// Удалить занятие
  Future<void> deleteLesson(String id) async {
    await _db.collection('schedule').doc(id).delete();
  }
}
