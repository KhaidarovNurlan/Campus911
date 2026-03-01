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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'college': college,
      'groupName': groupName,
      'role': role,
    };
  }

  bool get isHeadman => role == 'headman';
  bool get isStudent => role == 'student';
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

  factory LessonModel.fromMap(Map<String, dynamic> map, String id) {
    return LessonModel(
      id: id,
      subject: map['subject'] ?? '',
      teacher: map['teacher'] ?? '',
      room: map['room'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      type: map['type'] ?? 'lesson',
      dayOfWeek: map['dayOfWeek'] ?? '',
      college: map['college'] ?? '',
      groupName: map['groupName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'room': room,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type,
      'dayOfWeek': dayOfWeek,
      'college': college,
      'groupName': groupName,
    };
  }

  String get timeRange => '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  String get typeText {
    switch (type) {
      case 'lecture': return 'Lecture';
      case 'practice': return 'Practice';
      default: return 'Lesson';
    }
  }
}

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime date;
  final String college;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    required this.college,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map, String id) {
    return NewsModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'general',
      date: (map['date'] as Timestamp).toDate(),
      college: map['college'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'date': Timestamp.fromDate(date),
      'college': college,
    };
  }

  String get categoryEmoji {
    switch (category) {
      case 'events': return '📢';
      case 'academic': return '🎓';
      case 'sporting': return '🏀';
      default: return '📰';
    }
  }

  String get categoryName {
    switch (category) {
      case 'events': return 'Events';
      case 'academic': return 'Academic';
      case 'sporting': return 'Sporting';
      default: return 'General';
    }
  }
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

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isMe: map['isMe'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
      'isMe': isMe,
    };
  }
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

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? 'food',
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}

class NoteModel {
  final String id;
  final String title;
  final String? content;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    this.content,
    required this.createdAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String type;
  final String? description;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.description,
  });

  String get typeEmoji {
    switch (type) {
      case 'academic': return '📚';
      case 'deadline': return '⏰';
      case 'personal': return '🎉';
      case 'news': return '📢';
      default: return '📅';
    }
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'type': type,
      'description': description,
    };
  }
}