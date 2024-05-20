import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nesters/data/repository/user/recipient_user/recipient_user_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';

class FirebaseRecipientUserRepository implements RecipientUserRepository {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final String _userCollectionName = 'users';
  final String _chatCollectionName = 'chats';
  final String _participantFieldName = 'participants';
  final String _userIdKey = 'userId';

  @override
  Future<QuickChatUser?> getRecipientUser(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _store
          .collection(_userCollectionName)
          .where(_userIdKey, isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? user =
            querySnapshot.docs.first.data() as Map<String, dynamic>?;
        if (user == null) return null;
        return QuickChatUser.fromJson({
          ...user,
          "chatId": querySnapshot.docs.first.id,
        });
      } else {
        return null;
      }
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<QuickChatUser>> getRecipientUsers(
    String currentUserId,
    Function(String senderId, String receiverId) generateChatId,
  ) async {
    try {
      List<String> recipientUserIds = await _store
          .collection(_chatCollectionName)
          .where(_participantFieldName, arrayContains: currentUserId)
          .get()
          .then((value) {
        List<String> recipientUserIds = [];
        for (QueryDocumentSnapshot chat in value.docs) {
          List<String> participants = chat[_participantFieldName]
              .where((element) => element != currentUserId)
              .toList()
              .cast<String>();
          recipientUserIds.addAll(participants);
        }
        return recipientUserIds;
      });
      Future<List<QuickChatUser?>> recipientUsers = Future.wait([
        for (String recipientUserId in recipientUserIds)
          _store
              .collection(_userCollectionName)
              .doc(recipientUserId)
              .get()
              .then(
                (value) => value.exists
                    ? QuickChatUser.fromJson({
                        ...value.data() as Map<String, dynamic>,
                        "chatId": generateChatId(currentUserId, recipientUserId)
                      })
                    : null,
              )
      ]);
      return recipientUsers.then((value) {
        return value.whereType<QuickChatUser>().toList();
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  Stream<List<QuickChatUser>> getRecipientUsersStream(
    String userId,
    Function(String senderId, String receiverId) generateChatId,
  ) {
    return _store
        .collection(_chatCollectionName)
        .where(_participantFieldName, arrayContains: userId)
        .snapshots()
        .map((event) {
      List<String> recipientUserIds = [];
      for (QueryDocumentSnapshot chat in event.docs) {
        List<String> participants = chat[_participantFieldName]
            .where((element) => element != userId)
            .toList()
            .cast<String>();
        recipientUserIds.addAll(participants);
      }
      return recipientUserIds;
    }).asyncExpand((recipientUserIds) {
      return Stream.fromFuture(Future.wait([
        for (String recipientUserId in recipientUserIds)
          _store
              .collection(_userCollectionName)
              .doc(recipientUserId)
              .get()
              .then((value) {
            log('Recipient User: $value, ChatId ${value.id}');
            if (value.exists) {
              return QuickChatUser.fromJson({
                ...value.data() as Map<String, dynamic>,
                "chatId": generateChatId(userId, value.id)
              });
            } else {
              return null;
            }
          })
      ])).map((value) {
        return value.whereType<QuickChatUser>().toList();
      });
    });
  }
}
