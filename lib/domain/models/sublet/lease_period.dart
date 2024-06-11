class LeasePeriod {
  DateTime? startDate;
  DateTime? endDate;

  LeasePeriod({required this.startDate, required this.endDate});

  bool isLeaseActive() {
    final now = DateTime.now();
    if (startDate == null || endDate == null) {
      return false;
    }
    return now.isAfter(startDate!) && now.isBefore(endDate!);
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
    };
  }

  factory LeasePeriod.fromMap(Map<String, dynamic> map) {
    return LeasePeriod(
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
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
