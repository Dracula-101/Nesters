import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.isProfileCreated = false,
    this.isProfileCompleted = false,
  });

  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final bool isProfileCreated;
  final bool isProfileCompleted;

  @override
  List<Object?> get props => [id, name, email, photoUrl];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
    );
  }

  static User empty() {
    return const User(
      id: '',
      name: '',
      email: '',
      photoUrl: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isProfileCreated,
    bool? isProfileCompleted,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }
}
