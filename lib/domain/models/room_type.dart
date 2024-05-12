// ignore_for_file: constant_identifier_names

enum UserRoomType {
  NOT_DECIDED,
  PRIVATE,
  SHARED;

  static UserRoomType fromString(String value) {
    switch (value) {
      case 'PRIVATE':
        return UserRoomType.PRIVATE;
      case 'SHARED':
        return UserRoomType.SHARED;
      default:
        return UserRoomType.NOT_DECIDED;
    }
  }

  @override
  String toString() {
    switch (this) {
      case UserRoomType.PRIVATE:
        return 'PRIVATE';
      case UserRoomType.SHARED:
        return 'SHARED';
      default:
        return 'YET TO DECIDE';
    }
  }
}

enum FlatmateGenderType {
  MALE,
  FEMALE,
  MIX;

  static FlatmateGenderType fromString(String value) {
    switch (value) {
      case 'MALE':
        return FlatmateGenderType.MALE;
      case 'FEMALE':
        return FlatmateGenderType.FEMALE;
      default:
        return FlatmateGenderType.MIX;
    }
  }

  @override
  String toString() {
    switch (this) {
      case FlatmateGenderType.MALE:
        return 'MALE';
      case FlatmateGenderType.FEMALE:
        return 'FFEMALE';
      default:
        return 'MIX';
    }
  }
}
