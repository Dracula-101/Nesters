import 'package:nesters/domain/models/user/user.dart';

class QuickChatUser {
  final String? fullName;
  final String? photoUrl;
  final String? userId;
  final String? token;
  final String? chatId;
  final bool? isUserDeleted;

  QuickChatUser({
    this.fullName,
    this.photoUrl,
    this.userId,
    this.token,
    this.chatId,
    this.isUserDeleted,
  });

  QuickChatUser copyWith({
    String? fullName,
    String? photoUrl,
    String? userId,
    String? token,
    String? chatId,
    bool? isUserDeleted,
  }) {
    return QuickChatUser(
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      chatId: chatId ?? this.chatId,
      isUserDeleted: isUserDeleted ?? this.isUserDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'photoUrl': photoUrl,
      'userId': userId,
      'token': token,
      'chatId': chatId,
      'isUserDeleted': isUserDeleted,
    };
  }

  factory QuickChatUser.fromJson(Map<String, dynamic> map) {
    return QuickChatUser(
      fullName: map['fullName'],
      photoUrl: map['photoUrl'],
      userId: map['userId'],
      token: map['token'],
      chatId: map['chatId'] ?? '',
      isUserDeleted: map['isDeleted'],
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

  @override
  String toString() {
    return 'Name: $fullName, Photo: ${photoUrl?.substring(0, 5)}, ID: $userId, Token: *****, ChatID: $chatId';
  }
}
