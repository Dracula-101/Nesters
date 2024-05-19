import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';

abstract class RecipientChatUserRepository {
  Future<QuickChatUser?> getUserNameAndProfile(String userId);
}

class FirebaseRecipientChatUserRepository
    implements RecipientChatUserRepository {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final String _userCollectionName = 'users';
  final String _userIdKey = 'userId';

  @override
  Future<QuickChatUser?> getUserNameAndProfile(String userId) async {
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
}
