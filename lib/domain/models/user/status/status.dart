// ignore_for_file: constant_identifier_names

enum Status {
  ONLINE,
  OFFLINE,
  TYPING,
  UNKNOWN;

  @override
  String toString() {
    switch (this) {
      case Status.ONLINE:
        return 'Online';
      case Status.OFFLINE:
        return 'Offline';
      case Status.TYPING:
        return 'Typing...';
      default:
        return 'Unknown';
    }
  }

  static Status fromString(String status) {
    switch (status) {
      case 'Online':
        return Status.ONLINE;
      case 'Offline':
        return Status.OFFLINE;
      case 'Typing...':
        return Status.TYPING;
      default:
        return Status.UNKNOWN;
    }
  }
}
