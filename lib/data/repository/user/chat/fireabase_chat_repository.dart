import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:path/path.dart' as p;

import 'user_chat_repository.dart';

class FirebaseChatRepository extends RemoteChatRepository {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  String generateChatId(String senderId, String receiverId) {
    final sortedIds = [receiverId, senderId]..sort();
    return sortedIds.join('_');
  }

  @override
  Future<List<Message>> fetchChatMessages(String chatId) {
    try {
      return _store
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get()
          .then((value) =>
              value.docs.map((e) => Message.fromMap(e.data())).toList());
    } on Exception {
      rethrow;
    }
  }

  @override
  Stream<List<Message>> getChatMessages(String chatId) {
    try {
      return _store.collection('chats').doc(chatId).snapshots().map(
            (event) => event['messages']
                .map<Message>((e) => Message.fromMap(e))
                .toList()
                .reversed
                .toList(),
          );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String chatId, Message message) {
    try {
      DocumentReference docRef = _store.collection('chats').doc(chatId);
      return docRef.update({
        'messages': FieldValue.arrayUnion([message.toMap()])
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<bool> doesChatExist(String chatId) {
    try {
      return _store.collection('chats').doc(chatId).get().then((value) {
        return value.exists;
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> createChat(String chatId,
      {required String senderId, required String receiverId}) {
    try {
      return _store.collection('chats').doc(chatId).set({
        'id': chatId,
        'participants': [senderId, receiverId],
        'created_at': DateTime.now().toIso8601String(),
        'messages': []
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference fileRef = _firebaseStorage
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask uploadTask = fileRef.putFile(file);
    return uploadTask.then(
      (value) {
        if (value.state == TaskState.success) {
          return fileRef.getDownloadURL();
        }
      },
    );
  }
}
