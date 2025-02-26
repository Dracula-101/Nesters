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
      university: university,
      branchName: branchName,
      intakePeriod: intakePeriod,
      intakeYear: intakeYear,
      foodHabit: foodHabit,
      smokingHabit: smokingHabit,
      drinkingHabit: drinkingHabit,
      personType: personType,
      roomType: roomType,
      flatmateGenderPref: flatmateGenderPref,
    );
  }
}
