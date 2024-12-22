import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';

class UserFilter {
  // Filters
  String? universityName;
  String? branchName;
  String? gender;
  Language? language;
  UserFoodHabit? foodHabit;
  UserHabit? smokingHabit;
  UserHabit? drinkingHabit;
  PersonType? personType;
  UserRoomType? roomType;
  String? flatmateGenderPref;

  UserFilter({
    this.universityName,
    this.branchName,
    this.drinkingHabit,
    this.gender,
    this.language,
    this.foodHabit,
    this.smokingHabit,
    this.personType,
    this.roomType,
    this.flatmateGenderPref,
  });

  // copy with
  UserFilter copyWith({
    String? universityName,
    String? branchName,
    String? gender,
    Language? language,
    UserFoodHabit? foodHabit,
    UserHabit? smokingHabit,
    UserHabit? drinkingHabit,
    PersonType? personType,
    UserRoomType? roomType,
    String? flatmateGenderPref,
  }) {
    return UserFilter(
      universityName: universityName ?? this.universityName,
      branchName: branchName ?? this.branchName,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      foodHabit: foodHabit ?? this.foodHabit,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      personType: personType ?? this.personType,
      roomType: roomType ?? this.roomType,
      flatmateGenderPref: flatmateGenderPref ?? this.flatmateGenderPref,
    );
  }
}
