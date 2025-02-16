import 'package:equatable/equatable.dart';
import 'package:nesters/domain/models/college/university.dart';

class UserBasicProfile extends Equatable {
  final String? userId;
  final String? fullName;
  final String? email;
  final String? photoUrl;
  final DateTime? birthDate;
  final University? userCollege;
  final String? selectedCourseName;
  final String? gender;
  final String city;
  final String? state;
  final String? country;
  final String? intakePeriod;
  final int? intakeYear;

  const UserBasicProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.photoUrl,
    required this.birthDate,
    required this.userCollege,
    required this.selectedCourseName,
    required this.gender,
    required this.city,
    required this.state,
    required this.country,
    required this.intakePeriod,
    required this.intakeYear,
  });

  //tojson
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'full_name': fullName,
      'email': email,
      'profile_image': photoUrl,
      'birth_date': birthDate,
      'college': userCollege?.id,
      'selected_course_name': selectedCourseName,
      'city': city,
      'state': state,
      'country': country,
      'intake_period': intakePeriod,
      'intake_year': intakeYear,
    };
  }

  @override
  List<Object?> get props => [
        fullName,
        email,
        photoUrl,
        birthDate,
        userCollege,
        selectedCourseName,
        gender,
        city,
        state,
        country,
        intakePeriod,
        intakeYear,
      ];
}
