import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String photoUrl;

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
}
