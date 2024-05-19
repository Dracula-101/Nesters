import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nesters/data/repository/user/quick_user/recipient_quick_user_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';

class FirebaseRecipientQuickUserRepository
    implements RecipientQuickUserRepository {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final String _collectionName = 'users';
  final String _userIdKey = 'userId';

  @override
  Future<QuickChatUser?> getChatQuickUser(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _store
          .collection(_collectionName)
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
}
