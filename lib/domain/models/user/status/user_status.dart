import 'package:nesters/domain/models/user/status/status.dart';

class UserStatus {
  final Status? status;
  final DateTime? lastSeen;
  final String? userId;

  UserStatus({this.status, this.lastSeen, this.userId});

  factory UserStatus.fromJson(Map<dynamic, dynamic> json, String userId) {
    return UserStatus(
      status: Status.fromString(json['status']),
      lastSeen:
          json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      userId: userId,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    Map<String, dynamic> json = {};
    json['status'] = status.toString();
    if (status == Status.OFFLINE) {
      json['lastSeen'] = DateTime.now().toIso8601String();
    }
    return json;
  }
}
