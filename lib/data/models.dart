import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String college;
  final String groupName;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.college,
    required this.groupName,
    required this.role,
  });

  bool get isHeadman => role == 'headman';
  bool get isStudent => role == 'student';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      college: map['college'] ?? '',
      groupName: map['groupName'] ?? '',
      role: map['role'] ?? 'student',
    );
  }
}

class LessonModel {
  final String id;
  final String subject;
  final String teacher;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String dayOfWeek;
  final String college;
  final String groupName;

  LessonModel({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.dayOfWeek,
    required this.college,
    required this.groupName,
  });

  String get timeRange => '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get typeText {
    switch (type) {
      case 'lecture': return 'Лекция';
      case 'practice': return 'Практика';
      case 'lab': return 'Лабораторная';
      default: return 'Занятие';
    }
  }
}

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String groupId;
  final DateTime timestamp;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.groupId,
    required this.timestamp,
    required this.isMe,
  });
}

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

class TeacherModel {
  final String id;
  final String name;
  final String subject;
  final double rating;
  final int reviewCount;

  TeacherModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.rating,
    required this.reviewCount,
  });
  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      subject: map['subject'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subject': subject,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  TeacherModel copyWith({
    String? id,
    String? name,
    String? subject,
    double? rating,
    int? reviewCount,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
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

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      studentName: map['studentName'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'studentName': studentName,
      'rating': rating,
      'comment': comment,
      'date': date,
      'isAnonymous': isAnonymous,
    };
  }
}

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime date;
  final String? imageUrl;
  final String college;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    this.imageUrl,
    required this.college,
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

class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String type;
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

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      type: map['type'] ?? 'personal',
      description: map['description'],
      hasReminder: map['hasReminder'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'type': type,
      'description': description,
      'hasReminder': hasReminder,
    };
  }
}