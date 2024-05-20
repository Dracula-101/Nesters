import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nesters/data/repository/database/object_box/models/chat/chat_entity.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class MessageEntity {
  @Id()
  int? id;
  String messageId;
  String senderId;
  String content;
  String messageType;
  @Property(type: PropertyType.date)
  DateTime sentAt;
  int epochTime;
  final ToOne<ChatEntity> chat = ToOne<ChatEntity>();

  MessageEntity({
    this.id = 0,
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.messageType,
    required this.epochTime,
  });

  Message toMessage() {
    return Message(
      senderId: senderId,
      content: content,
      messageType: ChatMessageType.values.firstWhere(
        (e) => e.toString() == messageType,
      ),
      sentAt: Timestamp.fromDate(sentAt),
      epochTime: DateTime.fromMillisecondsSinceEpoch(epochTime),
    );
  }
}
