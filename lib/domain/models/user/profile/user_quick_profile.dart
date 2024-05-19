import 'package:equatable/equatable.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/domain/models/location/indian_city.dart';
import 'package:nesters/domain/models/location/indian_state.dart';
import 'package:nesters/domain/models/user/user.dart';

class UserQuickProfile extends Equatable {
  final String? id;
  final String? fullName;
  final String? profileImage;
  final String? selectedCourseName;
  final String? selectedCollegeName;
  final City? city;
  final IndianState? state;
  final int? workExperience;

  const UserQuickProfile({
    required this.id,
    required this.fullName,
    required this.profileImage,
    required this.selectedCourseName,
    required this.selectedCollegeName,
    required this.city,
    required this.state,
    required this.workExperience,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        profileImage,
        selectedCourseName,
        selectedCollegeName,
        city,
        state,
        workExperience,
      ];

  List<FieldValue> toFieldValues() {
    return [
      FieldValue(key: 'id', value: id),
      FieldValue(key: 'full_name', value: fullName),
      FieldValue(key: 'profile_image', value: profileImage),
      FieldValue(key: 'selected_course_name', value: selectedCourseName),
      FieldValue(key: 'selected_college_name', value: selectedCollegeName),
      FieldValue(key: 'city', value: city),
      FieldValue(key: 'state', value: state),
      FieldValue(key: 'work_experience', value: workExperience),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'profile_image': profileImage,
      'selected_course_name': selectedCourseName,
      'selected_college_name': selectedCollegeName,
      'city': city,
      'state': state,
      'work_experience': workExperience,
    };
  }

  //implement fromJson
  factory UserQuickProfile.fromJson(Map<String, dynamic> json) {
    try {
      return UserQuickProfile(
        id: json['id'] ?? '',
        fullName: json['full_name'] ?? '',
        profileImage: json['profile_image'] ?? '',
        selectedCourseName: json['selected_course_name'] ?? '',
        selectedCollegeName: json['selected_college_name'] ?? '',
        city: json['city'] != null ? City(name: json['city']) : null,
        state: json['state'] != null ? IndianState(name: json['state']) : null,
        workExperience: json['work_experience'] ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to parse UserQuickProfile: $e');
    }
  }

  User toUser() {
    return User(
      id: id!,
      fullName: fullName!,
      photoUrl: profileImage!,
      email: '',
    );
  }
}
