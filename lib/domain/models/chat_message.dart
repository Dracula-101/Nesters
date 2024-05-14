import 'package:dash_chat_2/dash_chat_2.dart';

class Message {
  final String? chatId;
  final String? senderId;
  final String? receiverId;
  final String? message;
  final DateTime? timestamp;

  Message({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Message copyWith({
    String? chatId,
    String? senderId,
    String? receiverId,
    String? message,
    DateTime? timestamp,
  }) {
    return Message(
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      chatId: map['message_id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message_id': chatId ?? '',
      'sender_id': senderId ?? '',
      'receiver_id': receiverId ?? '',
      'message': message ?? '',
      'timestamp': timestamp?.toIso8601String() ?? '',
    };
  }

  @override
  String toString() {
    return 'ChatMessage(chatId: $chatId, senderId: $senderId, receiverId: $receiverId, message: $message, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.chatId == chatId &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.message == message &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return chatId.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        message.hashCode ^
        timestamp.hashCode;
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
