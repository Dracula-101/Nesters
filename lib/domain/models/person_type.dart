// ignore_for_file: constant_identifier_names

enum PersonType {
  AMBIVERT,
  EXTROVERT,
  INTROVERT;

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
}
