import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:nesters/domain/models/chat_message_type.dart';

class Message {
  final String? chatId;
  final String? senderId;
  final String? receiverId;
  final String? message;
  final DateTime? timestamp;
  final ChatMessageType type;

  Message({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.type,
  });

  Message copyWith({
    String? chatId,
    String? senderId,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    ChatMessageType? type,
  }) {
    return Message(
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      chatId: map['message_id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      type:
          map['type'] == 'text' ? ChatMessageType.TEXT : ChatMessageType.IMAGE,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message_id': chatId ?? '',
      'sender_id': senderId ?? '',
      'receiver_id': receiverId ?? '',
      'message': message ?? '',
      'timestamp': timestamp?.toIso8601String() ?? '',
      'type': type == ChatMessageType.TEXT ? 'text' : 'image',
    };
  }

  @override
  String toString() {
    return 'ChatMessage(chatId: $chatId, senderId: $senderId, receiverId: $receiverId, message: $message, timestamp: $timestamp, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.chatId == chatId &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.type == type;
  }

  @override
  int get hashCode {
    return chatId.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        message.hashCode ^
        timestamp.hashCode ^
        type.hashCode;
  }

  ChatMessage toChatMessage() {
    return ChatMessage(
      text: message ?? '',
      user: ChatUser(
        id: senderId ?? '',
        firstName: '',
        lastName: '',
        profileImage: '',
      ),
      createdAt: timestamp ?? DateTime.now(),
    );
  }
}
