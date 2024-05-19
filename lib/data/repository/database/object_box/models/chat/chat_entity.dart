import 'package:nesters/data/repository/database/object_box/models/chat/message/message_entity.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ChatEntity {
  @Id()
  int id = 0;
  String chatId;
  String userId;
  String fullName;
  String photoUrl;
  String token;
  @Backlink()
  final ToMany<MessageEntity> messages = ToMany<MessageEntity>();

  ChatEntity({
    required this.chatId,
    required this.userId,
    required this.fullName,
    required this.photoUrl,
    required this.token,
  });

  @override
  String toString() {
    return 'fullName: $fullName, photoUrl: $photoUrl, chatId: $chatId, token: $token, userId: $userId';
  }

  User toUser() {
    return User(
      id: userId,
      fullName: fullName,
      email: '',
      photoUrl: photoUrl,
    );
  }

  //toQuickChatUser
  QuickChatUser toQuickChatUser() {
    return QuickChatUser(
      fullName: fullName,
      photoUrl: photoUrl,
      userId: userId,
      token: token,
      chatId: chatId,
    );
  }
}
