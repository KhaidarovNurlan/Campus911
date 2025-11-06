import '../data/models.dart';

class MockData {
  MockData._();

  // ========== ЧАТЫ ==========
  static List<ChatModel> get chats => [
    ChatModel(
      id: '1',
      name: 'Группа 1А',
      lastMessage: 'Кто сделал домашку?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 3,
      participants: ['1', '2', '3', '4'],
    ),
    ChatModel(
      id: '2',
      name: 'IT-клуб AITU',
      lastMessage: 'Завтра встреча в 15:00!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      participants: ['1', '5', '6', '7'],
    ),
    ChatModel(
      id: '3',
      name: 'Студсовет',
      lastMessage: 'Собираем предложения для ректора',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 1,
      participants: ['1', '8', '9'],
    ),
  ];
  static List<MessageModel> getMessagesForChat(String chatId) => [
    MessageModel(
      id: '1',
      text: 'Привет всем!',
      senderId: '2',
      senderName: 'Мария',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isMe: false,
    ),
    MessageModel(
      id: '2',
      text: 'Когда экзамен по математике?',
      senderId: '3',
      senderName: 'Иван',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      isMe: false,
    ),
    MessageModel(
      id: '3',
      text: '25 октября, в среду',
      senderId: '1',
      senderName: 'Вы',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      isMe: true,
    ),
    MessageModel(
      id: '4',
      text: 'Спасибо!',
      senderId: '3',
      senderName: 'Иван',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      isMe: false,
    ),
    MessageModel(
      id: '5',
      text: 'Кто сделал домашку?',
      senderId: '2',
      senderName: 'Мария',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: false,
    ),
  ];

  // ========== ПРЕПОДАВАТЕЛИ ==========
  static List<TeacherModel> get teachers => [
    TeacherModel(
      id: '1',
      name: 'Иванов Иван Иванович',
      subject: 'Математика',
      rating: 4.8,
      reviewCount: 24,
    ),
    TeacherModel(
      id: '2',
      name: 'Петрова Анна Сергеевна',
      subject: 'Физика',
      rating: 4.5,
      reviewCount: 18,
    ),
    TeacherModel(
      id: '3',
      name: 'Сидоров Владимир Михайлович',
      subject: 'Программирование',
      rating: 4.9,
      reviewCount: 32,
    ),
    TeacherModel(
      id: '4',
      name: 'Смирнова Ольга Николаевна',
      subject: 'Английский язык',
      rating: 4.7,
      reviewCount: 21,
    ),
  ];
  static List<ReviewModel> getReviewsForTeacher(String teacherId) => [
    ReviewModel(
      id: '1',
      teacherId: teacherId,
      studentName: 'Алексей И.',
      rating: 5.0,
      comment: 'Отличный преподаватель! Всё объясняет понятно и интересно.',
      date: DateTime.now().subtract(const Duration(days: 5)),
      isAnonymous: false,
    ),
    ReviewModel(
      id: '2',
      teacherId: teacherId,
      studentName: 'Аноним',
      rating: 4.5,
      comment: 'Хорошо преподаёт, но иногда строгий с дедлайнами.',
      date: DateTime.now().subtract(const Duration(days: 10)),
      isAnonymous: true,
    ),
    ReviewModel(
      id: '3',
      teacherId: teacherId,
      studentName: 'Мария К.',
      rating: 5.0,
      comment: 'Лучший препод! Всегда готов помочь после пар.',
      date: DateTime.now().subtract(const Duration(days: 15)),
      isAnonymous: false,
    ),
  ];

  // ========== СОБЫТИЯ В КАЛЕНДАРЕ ==========
  static List<EventModel> get events => [
    EventModel(
      id: '1',
      title: 'Экзамен по математике',
      date: DateTime.now().add(const Duration(days: 7)),
      type: 'academic',
      description: 'Аудитория 305, 10:00',
      hasReminder: true,
    ),
    EventModel(
      id: '2',
      title: 'Сдать курсовую работу',
      date: DateTime.now().add(const Duration(days: 3)),
      type: 'deadline',
      description: 'По программированию',
      hasReminder: true,
    ),
    EventModel(
      id: '3',
      title: 'День рождения друга',
      date: DateTime.now().add(const Duration(days: 5)),
      type: 'personal',
      description: 'Не забыть купить подарок!',
      hasReminder: true,
    ),
    EventModel(
      id: '4',
      title: 'Хакатон CodeFest',
      date: DateTime.now().add(const Duration(days: 10)),
      type: 'news',
      description: 'Регистрация до 23 октября',
      hasReminder: false,
    ),
  ];

  // ========== ПОСЕЩАЕМОСТЬ ==========
  static List<StudentAttendanceModel> get students => [
    StudentAttendanceModel(id: '1', name: 'Алексей Иванов', isPresent: false),
    StudentAttendanceModel(id: '2', name: 'Мария Петрова', isPresent: false),
    StudentAttendanceModel(id: '3', name: 'Иван Сидоров', isPresent: false),
    StudentAttendanceModel(id: '4', name: 'Анна Смирнова', isPresent: false),
    StudentAttendanceModel(id: '5', name: 'Дмитрий Козлов', isPresent: false),
    StudentAttendanceModel(id: '6', name: 'Елена Морозова', isPresent: false),
    StudentAttendanceModel(id: '7', name: 'Сергей Волков', isPresent: false),
    StudentAttendanceModel(id: '8', name: 'Ольга Новикова', isPresent: false),
  ];
}
