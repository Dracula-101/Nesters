import 'package:equatable/equatable.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';

class UserBasicProfile extends Equatable {
  final String userId;
  final String fullName;
  final String email;
  final String photoUrl;
  final DateTime birthDate;
  final String selectedCollegeName;
  final String selectedCourseName;
  final String gender;

  const UserBasicProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.photoUrl,
    required this.birthDate,
    required this.selectedCollegeName,
    required this.selectedCourseName,
    required this.gender,
  });

  //tojson
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'photo_url': photoUrl,
      'birth_date': birthDate,
      'selected_college_name': selectedCollegeName,
      'selected_course_name': selectedCourseName,
      'gender': gender
    };
  }

  @override
  List<Object?> get props => [
        fullName,
        email,
        photoUrl,
        birthDate,
        selectedCollegeName,
        selectedCourseName,
        gender
      ];

  List<FieldValue> toFieldValues() {
    return [
      FieldValue(key: 'id', value: userId),
      FieldValue(
          key: 'created_at',
          value: DateTime.now().toIso8601String().replaceAll("T", " ")),
      FieldValue(key: 'full_name', value: fullName),
      FieldValue(key: 'email', value: email),
      FieldValue(key: 'profile_image', value: photoUrl),
      FieldValue(
          key: 'birth_date',
          value: birthDate.toIso8601String().replaceAll("T", " ")),
      FieldValue(key: 'selected_college_name', value: selectedCollegeName),
      FieldValue(key: 'selected_course_name', value: selectedCourseName),
      FieldValue(key: 'gender', value: gender),
    ];
  }
}
