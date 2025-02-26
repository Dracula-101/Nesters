// ignore_for_file: constant_identifier_names

enum PersonType {
  AMBIVERT,
  EXTROVERT,
  INTROVERT,
  UNKNOWN;

  @override
  String toString() {
    switch (this) {
      case PersonType.AMBIVERT:
        return 'Ambivert';
      case PersonType.EXTROVERT:
        return 'Extrovert';
      case PersonType.INTROVERT:
        return 'Introvert';
      default:
        return 'Unknown';
    }
  }

  static PersonType fromString(String value) {
    switch (value) {
      case 'Ambivert':
        return PersonType.AMBIVERT;
      case 'Extrovert':
        return PersonType.EXTROVERT;
      case 'Introvert':
        return PersonType.INTROVERT;
      default:
        return PersonType.UNKNOWN;
    }
  }

  String toPersonTypeText() {
    switch (this) {
      case PersonType.AMBIVERT:
        return 'being an ambivert';
      case PersonType.EXTROVERT:
        return 'rocking the extrovert vibes';
      case PersonType.INTROVERT:
        return 'embracing the introvert lifestyle';
      default:
        return 'having an unknown personality type';
    }
  }

  String toTextFieldValue() {
    switch (this) {
      case PersonType.AMBIVERT:
        return 'Ambivert';
      case PersonType.EXTROVERT:
        return 'Extrovert';
      case PersonType.INTROVERT:
        return 'Introvert';
      default:
        return 'None';
    }
  }

  static List<PersonType> get types => [
        PersonType.AMBIVERT,
        PersonType.EXTROVERT,
        PersonType.INTROVERT,
      ];

  String? toSafeString() {
    if (this == PersonType.UNKNOWN) {
      return null;
    }
    return toString();
  }
}
