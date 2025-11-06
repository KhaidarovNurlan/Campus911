import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class AIChatProvider extends ChangeNotifier {
  final List<MessageModel> _messages = [];
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: 'AIzaSyBtlijqpMprM0qmBvQnRWqaekV_eK8L8qI',
  );

  bool isTyping = false;

  List<MessageModel> get messages => _messages;

  AIChatProvider() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('ai_chats')
        .orderBy('timestamp')
        .get();

    _messages
      ..clear()
      ..addAll(
        snapshot.docs.map((doc) {
          final data = doc.data();
          return MessageModel(
            id: doc.id,
            text: data['text'],
            senderId: data['senderId'],
            senderName: data['senderName'],
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            isMe: data['isMe'],
          );
        }),
      );
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: user.uid,
      senderName: user.displayName ?? 'Вы',
      timestamp: DateTime.now(),
      isMe: true,
    );

    _messages.add(userMsg);
    notifyListeners();
    await _saveMessage(user.uid, userMsg);

    isTyping = true;
    notifyListeners();

    try {
      final response = await model.generateContent([Content.text(text)]);
      final botText = response.text ?? 'Извини, я не понял вопрос.';

      final botMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: botText,
        senderId: 'bot',
        senderName: 'AI-помощник',
        timestamp: DateTime.now(),
        isMe: false,
      );

      _messages.add(botMsg);
      await _saveMessage(user.uid, botMsg);
    } catch (e) {
      final errorMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '⚠️ Ошибка при обращении к AI: $e',
        senderId: 'bot',
        senderName: 'AI-помощник',
        timestamp: DateTime.now(),
        isMe: false,
      );
      _messages.add(errorMsg);
      await _saveMessage(user.uid, errorMsg);
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  Future<void> _saveMessage(String userId, MessageModel message) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('ai_chats')
        .doc(message.id)
        .set({
          'text': message.text,
          'senderId': message.senderId,
          'senderName': message.senderName,
          'timestamp': message.timestamp,
          'isMe': message.isMe,
        });
  }

  Future<void> clearMessages() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _db.collection('users').doc(user.uid).collection('ai_chats');
    final snapshot = await ref.get();
    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    _messages.clear();
    notifyListeners();
  }
}
