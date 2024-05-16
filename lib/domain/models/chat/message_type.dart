// ignore_for_file: constant_identifier_names

enum ChatMessageType {
  TEXT,
  IMAGE;

  String get value {
    switch (this) {
      case TEXT:
        return 'TEXT';
      case IMAGE:
        return 'IMAGE';
      default:
        return 'TEXT';
    }
  }

  //toString
  @override
  String toString() {
    switch (this) {
      case TEXT:
        return 'TEXT';
      case IMAGE:
        return 'IMAGE';
      default:
        return 'TEXT';
    }
  }

  static ChatMessageType fromString(String value) {
    switch (value) {
      case 'TEXT':
        return TEXT;
      case 'IMAGE':
        return IMAGE;
      default:
        return TEXT;
    }
  }

  String toUserFriendlyString() {
    switch (this) {
      case TEXT:
        return 'text';
      case IMAGE:
        return 'image';
      default:
        return 'text';
    }
  }
}
