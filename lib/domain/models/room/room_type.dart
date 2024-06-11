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
        return 'PRIVATE';
      case UserRoomType.SHARED:
        return 'SHARED';
      case UserRoomType.ANYTHING:
        return 'ANYTHING';
      case UserRoomType.FLEX:
        return 'FLEX';
      default:
        return 'UNKNOWN';
    }
  }

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
}

enum FlatmateGenderType {
  MALE,
  FEMALE,
  MIX,
  UNKNOWN;

  static FlatmateGenderType fromString(String value) {
    switch (value) {
      case 'MALE':
        return FlatmateGenderType.MALE;
      case 'FEMALE':
        return FlatmateGenderType.FEMALE;
      case 'MIX':
        return FlatmateGenderType.MIX;
      default:
        return FlatmateGenderType.UNKNOWN;
    }
  }

  @override
  String toString() {
    switch (this) {
      case FlatmateGenderType.MALE:
        return 'MALE';
      case FlatmateGenderType.FEMALE:
        return 'FFEMALE';
      case FlatmateGenderType.MIX:
        return 'MIX';
      default:
        return 'UNKNOWN';
    }
  }
}
