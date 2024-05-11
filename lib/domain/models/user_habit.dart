// ignore_for_file: constant_identifier_names

enum UserHabit {
  REGULAR,
  OCCASIONAL,
  RARELY,
  NEVER;

  //toString function
  @override
  String toString() {
    switch (this) {
      case UserHabit.REGULAR:
        return 'Regular';
      case UserHabit.OCCASIONAL:
        return 'Occasional';
      case UserHabit.RARELY:
        return 'Rarely';
      case UserHabit.NEVER:
        return 'Never';
      default:
        return 'Unknown';
    }
  }

  //from string
  static UserHabit fromString(String value) {
    switch (value) {
      case 'Regular':
        return UserHabit.REGULAR;
      case 'Occasional':
        return UserHabit.OCCASIONAL;
      case 'Rarely':
        return UserHabit.RARELY;
      case 'Never':
        return UserHabit.NEVER;
      default:
        return UserHabit.NEVER;
    }
  }
}

enum UserFoodHabit {
  VEGAN,
  VEGETARIAN,
  PESCATARIAN,
  EGGTARIAN,
  NON_VEGETERIAN;

  //toString function
  @override
  String toString() {
    switch (this) {
      case UserFoodHabit.VEGAN:
        return 'Vegan';
      case UserFoodHabit.VEGETARIAN:
        return 'Vegetarian';
      case UserFoodHabit.PESCATARIAN:
        return 'Pescatarian';
      case UserFoodHabit.EGGTARIAN:
        return 'Eggtarian';
      case UserFoodHabit.NON_VEGETERIAN:
        return 'Omnivore';
      default:
        return 'Unknown';
    }
  }

  //from string
  static UserFoodHabit fromString(String value) {
    switch (value) {
      case 'Vegan':
        return UserFoodHabit.VEGAN;
      case 'Vegetarian':
        return UserFoodHabit.VEGETARIAN;
      case 'Pescatarian':
        return UserFoodHabit.PESCATARIAN;
      case 'Eggtarian':
        return UserFoodHabit.EGGTARIAN;
      case 'Omnivore':
        return UserFoodHabit.NON_VEGETERIAN;
      default:
        return UserFoodHabit.NON_VEGETERIAN;
    }
  }
}

enum UserCookingSkill {
  NEWBIE,
  INTERMEDIATE,
  CHEF;

  @override
  String toString() {
    switch (this) {
      case UserCookingSkill.NEWBIE:
        return 'Newbie';
      case UserCookingSkill.INTERMEDIATE:
        return 'Intermediate';
      case UserCookingSkill.CHEF:
        return 'Chef';
      default:
        return 'Unknown';
    }
  }

  // from string
  static UserCookingSkill fromString(String value) {
    switch (value) {
      case 'Newbie':
        return UserCookingSkill.NEWBIE;
      case 'Intermediate':
        return UserCookingSkill.INTERMEDIATE;
      case 'Chef':
        return UserCookingSkill.CHEF;
      default:
        return UserCookingSkill.NEWBIE;
    }
  }
}

enum UserCleanlinessHabit {
  MESSY,
  DECENTLY_CLEAN,
  VERY_CLEAN,
  OBSESSIVELY_CLEAN;

  @override
  String toString() {
    switch (this) {
      case UserCleanlinessHabit.MESSY:
        return 'Messy';
      case UserCleanlinessHabit.DECENTLY_CLEAN:
        return 'Decently Clean';
      case UserCleanlinessHabit.VERY_CLEAN:
        return 'Very Clean';
      case UserCleanlinessHabit.OBSESSIVELY_CLEAN:
        return 'Obsessively Clean';
      default:
        return 'Unknown';
    }
  }

  static UserCleanlinessHabit fromString(String value) {
    switch (value) {
      case 'Messy':
        return UserCleanlinessHabit.MESSY;
      case 'Decently Clean':
        return UserCleanlinessHabit.DECENTLY_CLEAN;
      case 'Very Clean':
        return UserCleanlinessHabit.VERY_CLEAN;
      case 'Obsessively Clean':
        return UserCleanlinessHabit.OBSESSIVELY_CLEAN;
      default:
        return UserCleanlinessHabit.MESSY;
    }
  }
}
