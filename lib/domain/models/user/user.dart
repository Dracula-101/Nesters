import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.photoUrl,
    this.accessToken,
    this.isProfileCreated = false,
    this.isProfileCompleted = false,
    this.isUserDeleted = false,
  });

  final String id;
  final String fullName;
  final String email;
  final String photoUrl;
  final String? accessToken;
  final bool isProfileCreated;
  final bool isProfileCompleted;
  final bool isUserDeleted;

  @override
  List<Object?> get props => [id, fullName, email, photoUrl];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      accessToken: json['accessToken'],
      isUserDeleted: json['isUserDeleted'] ?? false,
    );
  }

  static User empty() {
    return const User(
      id: '',
      fullName: '',
      email: '',
      photoUrl: '',
      accessToken: '',
      isUserDeleted: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'accessToken': accessToken,
      'isUserDeleted': isUserDeleted,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? photoUrl,
    bool? isProfileCreated,
    bool? isProfileCompleted,
    bool? isUserDeleted,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      accessToken: accessToken,
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      isUserDeleted: isUserDeleted ?? this.isUserDeleted,
    );
  }
}
