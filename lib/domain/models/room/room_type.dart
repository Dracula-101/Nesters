// ignore_for_file: constant_identifier_names
enum UserRoomType {
  ANYTHING,
  PRIVATE,
  SHARED,
  FLEX,
  UNKNOWN;

  static UserRoomType fromString(String value) {
    switch (value) {
      case 'Private':
        return UserRoomType.PRIVATE;
      case 'Shared':
        return UserRoomType.SHARED;
      case 'Anything':
        return UserRoomType.ANYTHING;
      case 'Flex':
        return UserRoomType.FLEX;
      default:
        return UserRoomType.UNKNOWN;
    }
  }

  @override
  String toString() {
    switch (this) {
      case UserRoomType.PRIVATE:
        return 'Private';
      case UserRoomType.SHARED:
        return 'Shared';
      case UserRoomType.ANYTHING:
        return 'Anything';
      case UserRoomType.FLEX:
        return 'Flex';
      default:
        return 'Not Selected';
    }
  }

  static List<UserRoomType> toList() => [
        UserRoomType.PRIVATE,
        UserRoomType.SHARED,
        UserRoomType.FLEX,
      ];

  String toUI() {
    switch (this) {
      case UserRoomType.PRIVATE:
        return 'Private';
      case UserRoomType.SHARED:
        return 'Shared';
      case UserRoomType.ANYTHING:
        return 'Anything';
      case UserRoomType.FLEX:
        return 'Flex';
      default:
        return 'Unknown';
    }
  }

  String? toSafeString() {
    if (this == UserRoomType.UNKNOWN) {
      return null;
    }
    return toString();
  }
}

enum FlatmateGenderType {
  MALE,
  FEMALE,
  MIX,
  UNKNOWN;

  static FlatmateGenderType fromString(String value) {
    switch (value) {
      case 'Male':
        return FlatmateGenderType.MALE;
      case 'Female':
        return FlatmateGenderType.FEMALE;
      case 'Mix':
        return FlatmateGenderType.MIX;
      default:
        return FlatmateGenderType.UNKNOWN;
    }
  }

  @override
  String toString() {
    switch (this) {
      case FlatmateGenderType.MALE:
        return 'Male';
      case FlatmateGenderType.FEMALE:
        return 'Female';
      case FlatmateGenderType.MIX:
        return 'Mix';
      default:
        return 'Unknown';
    }
  }

  String? toSafeString() {
    if (this == FlatmateGenderType.UNKNOWN) {
      return null;
    }
    return toString();
  }
}
