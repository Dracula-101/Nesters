class LeasePeriod {
  DateTime? startDate;
  DateTime? endDate;

  LeasePeriod({this.startDate, this.endDate});

  bool isLeaseActive() {
    final now = DateTime.now();
    if (startDate == null || endDate == null) {
      return false;
    }
    return now.isAfter(startDate!) && now.isBefore(endDate!);
  }

  Map<String, dynamic> toMap() {
    return {
      'start_date': startDate?.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
    };
  }

  factory LeasePeriod.fromMap(Map<String, dynamic> map) {
    return LeasePeriod(
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] ?? 0),
    );
  }

  LeasePeriod copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return LeasePeriod(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
