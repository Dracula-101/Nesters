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
        return QuickChatUser.fromJson(user);
      } else {
        return null;
      }
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<QuickChatUser>> getRecipientUsers(
      String currentUserId, Function(String, String) generateChatId) async {
    try {
      List<String> recipientUserIds = await _store
          .collection(_chatCollectionName)
          .where(_participantFieldName, arrayContains: currentUserId)
          .get()
          .then((value) {
        return value.docs
            .map((e) => e[_participantFieldName]
                .where((element) => element != currentUserId)
                .first as String)
            .toList();
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
                        "chatId": generateChatId(recipientUserId, currentUserId)
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
}
