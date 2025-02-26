import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.photoUrl,
    this.accessToken,
    this.isProfileCreated = false,
  });

  final String id;
  final String fullName;
  final String email;
  final String photoUrl;
  final String? accessToken;
  final bool isProfileCreated;

  @override
  List<Object?> get props => [id, fullName, email, photoUrl, accessToken];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      accessToken: json['accessToken'],
    );
  }

  static User empty() {
    return const User(
      id: '',
      fullName: '',
      email: '',
      photoUrl: '',
      accessToken: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'accessToken': accessToken,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? photoUrl,
    bool? isProfileCreated,
    String? profileUrl,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      accessToken: accessToken,
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
    );
  }

  @override
  String toString() {
    return 'User { id: $id, fullName: $fullName, email: $email, photoUrl: $photoUrl}';
  }
}
