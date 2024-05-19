import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? senderId;
  String? content;
  ChatMessageType? messageType;
  Timestamp? sentAt;
  // DateTime? epochTime;

  Message({
    this.senderId,
    this.content,
    this.messageType,
    this.sentAt,
    // this.epochTime,
  });

  //fromMap
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      content: map['content'],
      messageType: ChatMessageType.values.byName(
        map['messageType'],
      ),
      sentAt: map['sentAt'],
      // epochTime: DateTime.fromMillisecondsSinceEpoch(map['epochTime'] ?? ''),
    );
  }

  //toMap
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'messageType': messageType.toString(),
      'sentAt': sentAt,
      // 'epochTime': epochTime?.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'senderId: $senderId, content: $content';
  }
}
