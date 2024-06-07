// ignore_for_file: constant_identifier_names

import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/user/user.dart';

class Request {
  final RequestPerson sender;
  final RequestPerson receiver;
  final DateTime sentAt;
  final bool isAccepted;
  final int attempt;
  final bool isBanned;

  Request({
    required this.sender,
    required this.receiver,
    required this.sentAt,
    required this.isAccepted,
    required this.attempt,
    required this.isBanned,
  });

  Map<String, dynamic> toSenderMap() {
    return {
      'info': {
        'id': sender.id,
        'name': sender.name,
        'photoUrl': sender.photoUrl,
      },
      'sentAt': sentAt.millisecondsSinceEpoch,
      'isAccepted': isAccepted,
      'attempt': attempt,
      'isBanned': isBanned,
    };
  }

  Map<String, dynamic> toReceiverMap() {
    return {
      'info': {
        'id': receiver.id,
        'name': receiver.name,
        'photoUrl': receiver.photoUrl,
      },
      'sentAt': sentAt.millisecondsSinceEpoch,
      'isAccepted': isAccepted,
      'attempt': attempt,
      'isBanned': isBanned,
    };
  }

  factory Request.fromSenderRequest(Map<String, dynamic> data, User receiver) {
    return Request(
      sender: RequestPerson(
        id: data['info']?['id'] ?? '',
        name: data['info']?['name'] ?? '',
        photoUrl: data['info']?['photoUrl'] ?? '',
        type: RequestType.SENDER,
      ),
      receiver: RequestPerson(
        id: receiver.id,
        name: receiver.fullName,
        photoUrl: receiver.photoUrl,
        type: RequestType.RECEIVER,
      ),
      sentAt: DateTime.fromMillisecondsSinceEpoch(data['sentAt']),
      isAccepted: data['isAccepted'] ?? false,
      attempt: data['attempt'] ?? 0,
      isBanned: data['isBanned'] ?? false,
    );
  }

  factory Request.fromReceiverRequest(Map<String, dynamic> data, User sender) {
    return Request(
      sender: RequestPerson(
        id: sender.id,
        name: sender.fullName,
        photoUrl: sender.photoUrl,
        type: RequestType.SENDER,
      ),
      receiver: RequestPerson(
        id: data['info']?['id'] ?? '',
        name: data['info']?['name'] ?? '',
        photoUrl: data['info']?['photoUrl'] ?? '',
        type: RequestType.RECEIVER,
      ),
      sentAt: DateTime.fromMillisecondsSinceEpoch(data['sentAt']),
      isAccepted: data['isAccepted'] ?? false,
      attempt: data['attempt'] ?? 0,
      isBanned: data['isBanned'] ?? false,
    );
  }

  factory Request.createRequest(User currentUser, User receiverUser) {
    return Request(
      sender: RequestPerson(
        id: currentUser.id,
        name: currentUser.fullName,
        photoUrl: currentUser.photoUrl,
        type: RequestType.SENDER,
      ),
      receiver: RequestPerson(
        id: receiverUser.id,
        name: receiverUser.fullName,
        photoUrl: receiverUser.photoUrl,
        type: RequestType.RECEIVER,
      ),
      sentAt: DateTime.now(),
      isAccepted: false,
      attempt: 0,
      isBanned: false,
    );
  }

  factory Request.createReq(
      QuickChatUser currentUser, QuickChatUser receiverUser) {
    return Request(
      sender: RequestPerson(
        id: currentUser.userId ?? '',
        name: currentUser.fullName ?? '',
        photoUrl: currentUser.photoUrl ?? '',
        type: RequestType.SENDER,
      ),
      receiver: RequestPerson(
        id: receiverUser.userId ?? '',
        name: receiverUser.fullName ?? '',
        photoUrl: receiverUser.photoUrl ?? '',
        type: RequestType.RECEIVER,
      ),
      sentAt: DateTime.now(),
      isAccepted: false,
      attempt: 0,
      isBanned: false,
    );
  }
}

class RequestPerson {
  final String id;
  final String name;
  final String photoUrl;
  final RequestType type;

  RequestPerson({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.type,
  });

  QuickChatUser toQuickChatUser() {
    return QuickChatUser(
      userId: id,
      fullName: name,
      photoUrl: photoUrl,
    );
  }
}

enum RequestType {
  SENDER,
  RECEIVER;

  String get name {
    switch (this) {
      case RequestType.SENDER:
        return 'Sender';
      case RequestType.RECEIVER:
        return 'Receiver';
    }
  }
}
