// 📦 Все модели данных приложения

// ========== USER MODEL ==========

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String university;
  final String gender;
  final String role; // 'student' или 'headman'
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.university,
    required this.gender,
    required this.role,
    this.photoUrl,
  });

  bool get isHeadman => role == 'headman';
  bool get isStudent => role == 'student';
}

// ========== SCHEDULE MODEL ==========

class LessonModel {
  final String id;
  final String subject;
  final String teacher;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'lecture', 'practice', 'lab'
  final String dayOfWeek; // 'Понедельник', 'Вторник', и т.д.

  LessonModel({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.dayOfWeek,
  });

  String get timeRange => '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get typeText {
    switch (type) {
      case 'lecture':
        return 'Лекция';
      case 'practice':
        return 'Практика';
      case 'lab':
        return 'Лабораторная';
      default:
        return 'Занятие';
    }
  }
}

// ========== CHAT MODEL ==========

class ChatModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<String> participants;

  ChatModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.participants,
  });
}

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isMe,
  });
}

// ========== EXPENSE MODEL ==========

class ExpenseModel {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  String get categoryEmoji {
    switch (category) {
      case 'transport':
        return '🚌';
      case 'food':
        return '🍔';
      case 'books':
        return '📚';
      case 'housing':
        return '🏠';
      case 'entertainment':
        return '🎮';
      case 'health':
        return '💊';
      case 'clothing':
        return '👕';
      case 'communication':
        return '📱';
      default:
        return '💰';
    }
  }

  String get categoryName {
    switch (category) {
      case 'transport':
        return 'Транспорт';
      case 'food':
        return 'Еда';
      case 'books':
        return 'Книги';
      case 'housing':
        return 'Проживание';
      case 'entertainment':
        return 'Развлечения';
      case 'health':
        return 'Здоровье';
      case 'clothing':
        return 'Одежда';
      case 'communication':
        return 'Связь';
      default:
        return 'Другое';
    }
  }
}

// ========== TEACHER MODEL ==========

class TeacherModel {
  final String id;
  final String name;
  final String subject;
  final double rating;
  final int reviewCount;
  final String? photoUrl;

  TeacherModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.rating,
    required this.reviewCount,
    this.photoUrl,
  });
}

class ReviewModel {
  final String id;
  final String teacherId;
  final String studentName;
  final double rating;
  final String comment;
  final DateTime date;
  final bool isAnonymous;

  ReviewModel({
    required this.id,
    required this.teacherId,
    required this.studentName,
    required this.rating,
    required this.comment,
    required this.date,
    this.isAnonymous = false,
  });

  String get displayName => isAnonymous ? 'Аноним' : studentName;
}

// ========== NEWS MODEL ==========

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String
  category; // 'academic', 'events', 'achievements', 'announcements'
  final DateTime date;
  final String? imageUrl;
  final String university;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    this.imageUrl,
    required this.university,
  });

  String get categoryEmoji {
    switch (category) {
      case 'academic':
        return '🎓';
      case 'events':
        return '🎉';
      case 'achievements':
        return '🏆';
      case 'announcements':
        return '📢';
      default:
        return '📰';
    }
  }

  String get categoryName {
    switch (category) {
      case 'academic':
        return 'Академические';
      case 'events':
        return 'События';
      case 'achievements':
        return 'Достижения';
      case 'announcements':
        return 'Объявления';
      default:
        return 'Новости';
    }
  }
}

// ========== EVENT MODEL (для календаря) ==========

class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String type; // 'academic', 'deadline', 'personal', 'news'
  final String? description;
  final bool hasReminder;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.description,
    this.hasReminder = false,
  });

  String get typeEmoji {
    switch (type) {
      case 'academic':
        return '📚';
      case 'deadline':
        return '⏰';
      case 'personal':
        return '🎉';
      case 'news':
        return '📢';
      default:
        return '📅';
    }
  }
}

// ========== ATTENDANCE MODEL ==========

class StudentAttendanceModel {
  final String id;
  final String name;
  final String? photoUrl;
  final bool isPresent;

  StudentAttendanceModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.isPresent = false,
  });

  StudentAttendanceModel copyWith({bool? isPresent}) {
    return StudentAttendanceModel(
      id: id,
      name: name,
      photoUrl: photoUrl,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}

class AttendanceRecordModel {
  final String id;
  final DateTime date;
  final List<StudentAttendanceModel> students;

  AttendanceRecordModel({
    required this.id,
    required this.date,
    required this.students,
  });

  int get presentCount => students.where((s) => s.isPresent).length;
  int get absentCount => students.where((s) => !s.isPresent).length;
  double get attendancePercentage =>
      students.isEmpty ? 0 : (presentCount / students.length) * 100;
}
