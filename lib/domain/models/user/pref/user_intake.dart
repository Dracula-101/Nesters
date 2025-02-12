// ignore_for_file: constant_identifier_names

enum UserIntake {
  SPRING,
  SUMMER,
  FALL,
  WINTER,
  UNKNOWN;

  static UserIntake fromString(String intake) {
    switch (intake) {
      case 'Spring':
        return UserIntake.SPRING;
      case 'Summer':
        return UserIntake.SUMMER;
      case 'Fall':
        return UserIntake.FALL;
      case 'Winter':
        return UserIntake.WINTER;
      default:
        return UserIntake.UNKNOWN;
    }
  }

  @override
  String toString() {
    switch (this) {
      case UserIntake.SPRING:
        return 'Spring';
      case UserIntake.SUMMER:
        return 'Summer';
      case UserIntake.FALL:
        return 'Fall';
      case UserIntake.WINTER:
        return 'Winter';
      default:
        return 'Not Selected';
    }
  }

  static List<UserIntake> get safeValues => [
        UserIntake.SPRING,
        UserIntake.SUMMER,
        UserIntake.FALL,
        UserIntake.WINTER,
      ];
}
