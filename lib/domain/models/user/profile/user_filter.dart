import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/pref/user_intake.dart';

class UserFilter {
  // Filters
  University? university;
  String? branchName;
  UserIntake? intakePeriod;
  int? intakeYear;
  UserFoodHabit? foodHabit;
  UserHabit? smokingHabit;
  UserHabit? drinkingHabit;
  PersonType? personType;
  UserRoomType? roomType;
  String? flatmateGenderPref;

  UserFilter({
    this.university,
    this.branchName,
    this.intakePeriod,
    this.intakeYear,
    this.drinkingHabit,
    this.foodHabit,
    this.smokingHabit,
    this.personType,
    this.roomType,
    this.flatmateGenderPref,
  });

  // copy with
  UserFilter copyWith({
    University? university,
    String? branchName,
    UserIntake? intakePeriod,
    int? intakeYear,
    String? gender,
    UserFoodHabit? foodHabit,
    UserHabit? smokingHabit,
    UserHabit? drinkingHabit,
    PersonType? personType,
    UserRoomType? roomType,
    String? flatmateGenderPref,
  }) {
    return UserFilter(
      university: university ?? this.university,
      branchName: branchName ?? this.branchName,
      intakePeriod: intakePeriod ?? this.intakePeriod,
      intakeYear: intakeYear ?? this.intakeYear,
      foodHabit: foodHabit ?? this.foodHabit,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      personType: personType ?? this.personType,
      roomType: roomType ?? this.roomType,
      flatmateGenderPref: flatmateGenderPref ?? this.flatmateGenderPref,
    );
  }
}
