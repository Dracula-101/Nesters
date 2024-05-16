// ignore_for_file: constant_identifier_names

enum UserHabit {
  REGULAR,
  OCCASIONAL,
  RARELY,
  NEVER,
  UNKNOWN;

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

  String toDrinkingHabitText() {
    switch (this) {
      case UserHabit.REGULAR:
        return 'sipping drinks regularly';
      case UserHabit.OCCASIONAL:
        return 'indulging in drinks occasionally';
      case UserHabit.RARELY:
        return 'rarely touching a drop';
      case UserHabit.NEVER:
        return 'not a drinker';
      default:
        return 'having an unknown drinking habit';
    }
  }

  String toSmokingHabitText() {
    switch (this) {
      case UserHabit.REGULAR:
        return 'puffing away regularly';
      case UserHabit.OCCASIONAL:
        return 'enjoying a smoke occasionally';
      case UserHabit.RARELY:
        return 'smoking only rarely';
      case UserHabit.NEVER:
        return 'not a smoker';
      default:
        return 'having an unknown smoking habit';
    }
  }
}

enum UserFoodHabit {
  VEGAN,
  VEGETARIAN,
  PESCATARIAN,
  EGGETARIAN,
  NON_VEGETERIAN,
  UNKNOWN;

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
      case UserFoodHabit.EGGETARIAN:
        return 'Eggetarian';
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
      case 'Eggetarian':
        return UserFoodHabit.EGGETARIAN;
      case 'Omnivore':
        return UserFoodHabit.NON_VEGETERIAN;
      default:
        return UserFoodHabit.UNKNOWN;
    }
  }

  String toUserFriendlyString() {
    switch (this) {
      case UserFoodHabit.VEGAN:
        return 'vegan';
      case UserFoodHabit.VEGETARIAN:
        return 'vegetarian';
      case UserFoodHabit.PESCATARIAN:
        return 'pescatarian';
      case UserFoodHabit.EGGETARIAN:
        return 'eggetarian';
      case UserFoodHabit.NON_VEGETERIAN:
        return 'non-vegetarian';
      default:
        return 'having an unknown smoking habit';
    }
  }
}

enum UserCookingSkill {
  NEWBIE,
  INTERMEDIATE,
  CHEF,
  UNKNOWN;

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
        return UserCookingSkill.UNKNOWN;
    }
  }

  String toUserFriendlyString() {
    switch (this) {
      case UserCookingSkill.NEWBIE:
        return 'just starting to cook';
      case UserCookingSkill.INTERMEDIATE:
        return 'have some experience in cooking';
      case UserCookingSkill.CHEF:
        return 'an experienced cook';
      default:
        return 'having an unknown drinking habit';
    }
  }
}

enum UserCleanlinessHabit {
  MESSY,
  DECENTLY_CLEAN,
  VERY_CLEAN,
  OBSESSIVELY_CLEAN,
  UNKNOWN;

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
        return UserCleanlinessHabit.UNKNOWN;
    }
  }

  String toUserFriendlyString() {
    switch (this) {
      case UserCleanlinessHabit.MESSY:
        return 'living in organized chaos';
      case UserCleanlinessHabit.DECENTLY_CLEAN:
        return 'maintaining a decent level of cleanliness';
      case UserCleanlinessHabit.VERY_CLEAN:
        return 'keeping things very clean';
      case UserCleanlinessHabit.OBSESSIVELY_CLEAN:
        return 'being obsessively clean';
      default:
        return 'having an unknown cleanliness habit';
    }
  }
}
