import 'package:nesters/domain/models/user/user.dart';

class QuickChatUser {
  final String? fullName;
  final String? photoUrl;
  final String? userId;
  final String? token;
  final String? chatId;

  QuickChatUser({
    this.fullName,
    this.photoUrl,
    this.userId,
    this.token,
    this.chatId,
  });

  QuickChatUser copyWith({
    String? fullName,
    String? photoUrl,
    String? userId,
    String? token,
    String? chatId,
  }) {
    return QuickChatUser(
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      chatId: chatId ?? this.chatId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'photoUrl': photoUrl,
      'userId': userId,
      'token': token,
      'chatId': chatId,
    };
  }

  factory QuickChatUser.fromJson(Map<String, dynamic> map) {
    return QuickChatUser(
      fullName: map['fullName'],
      photoUrl: map['photoUrl'],
      userId: map['userId'],
      token: map['token'],
      chatId: map['chatId'] ?? '',
    );
  }

  User toUser() {
    return User(
      id: userId ?? '',
      email: '',
      fullName: fullName ?? '',
      photoUrl: photoUrl ?? '',
    );
  }
}
