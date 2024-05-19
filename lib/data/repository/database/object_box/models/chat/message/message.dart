import 'package:nesters/data/repository/database/object_box/models/chat/chat.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class MessageEntity {
  @Id()
  int? id;
  String senderId;
  String content;
  ChatMessageType messageType;
  @Property(type: PropertyType.date)
  DateTime sentAt;
  final ToOne<ChatEntity> chat = ToOne<ChatEntity>();

  MessageEntity({
    this.id = 0,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.messageType = ChatMessageType.TEXT,
  });

  int get dbMessageType {
    _ensureStableEnumValues();
    return messageType.index;
  }

  set dbMessageType(int value) {
    _ensureStableEnumValues();
    messageType = ChatMessageType.values[value];
  }

  _ensureStableEnumValues() {
    assert(ChatMessageType.IMAGE.index == 0);
    assert(ChatMessageType.TEXT.index == 1);
  }
}
