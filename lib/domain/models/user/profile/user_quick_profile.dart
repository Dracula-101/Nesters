import 'package:equatable/equatable.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/domain/models/location/location_city.dart';
import 'package:nesters/domain/models/location/location_country.dart';
import 'package:nesters/domain/models/location/location_state.dart';
import 'package:nesters/domain/models/user/pref/user_intake.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class UserQuickProfile extends Equatable {
  final String? id;
  final String? fullName;
  final String? profileImage;
  final String? selectedCourseName;
  final String? selectedCollegeName;
  final UserIntake? intakePeriod;
  final int? intakeYear;
  final LocationCity? city;
  final LocationState? state;
  final LocationCountry? country;
  final int? workExperience;
  final bool? hasRoommateFound;

  const UserQuickProfile({
    required this.id,
    required this.fullName,
    required this.profileImage,
    required this.selectedCourseName,
    required this.selectedCollegeName,
    required this.city,
    required this.state,
    required this.country,
    required this.workExperience,
    required this.intakePeriod,
    required this.intakeYear,
    required this.hasRoommateFound,
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
        country,
        workExperience,
        intakePeriod,
        intakeYear,
        hasRoommateFound,
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
      FieldValue(key: 'country', value: country),
      FieldValue(key: 'work_experience', value: workExperience),
      FieldValue(key: 'intake_period', value: intakePeriod),
      FieldValue(key: 'intake_year', value: intakeYear),
      FieldValue(key: 'has_roomate_found', value: hasRoommateFound),
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
      'country': country,
      'work_experience': workExperience,
      'intake_period': intakePeriod,
      'intake_year': intakeYear,
      'has_roommate_found': hasRoommateFound,
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
        city: json['city'] != null ? LocationCity(name: json['city']) : null,
        state:
            json['state'] != null ? LocationState(name: json['state']) : null,
        country: json['country'] != null
            ? LocationCountry(name: json['country'])
            : null,
        workExperience: json['work_experience'] ?? 0,
        intakePeriod: json['intake_period'] != null
            ? UserIntake.fromString(json['intake_period'])
            : UserIntake.FALL,
        intakeYear: json['intake_year'] ?? DateTime.now().year,
        hasRoommateFound: json['has_rooommate_found'] ?? true,
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

  String toUserLocation() {
    String location = '';
    if (city?.name != null && city?.name.isEmpty == false) {
      location = '${city?.name.toTitleCase}, ';
    }
    if (state?.name != null && state?.name.isEmpty == false) {
      location += state?.name.toTitleCase ?? '';
    }
    if (country?.name != null && country?.name.isEmpty == false) {
      location += ', ${country?.name.toTitleCase}';
    }
    if (location.isEmpty) {
      location = 'Location Not Available';
    }
    return location;
  }
}
