import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.photoUrl,
    this.isProfileCreated = false,
    this.isProfileCompleted = false,
  });

  final String id;
  final String fullName;
  final String email;
  final String photoUrl;
  final bool isProfileCreated;
  final bool isProfileCompleted;

  @override
  List<Object?> get props => [id, fullName, email, photoUrl];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
    );
  }

  static User empty() {
    return const User(
      id: '',
      fullName: '',
      email: '',
      photoUrl: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? photoUrl,
    bool? isProfileCreated,
    bool? isProfileCompleted,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }
}
