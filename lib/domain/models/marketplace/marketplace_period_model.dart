class MarketplacePeriodModel {
  DateTime? periodTill;
  DateTime? periodFrom;

  MarketplacePeriodModel({this.periodTill, this.periodFrom});

  factory MarketplacePeriodModel.fromJson(Map<String, dynamic> json) {
    return MarketplacePeriodModel(
      periodTill: json['period_till'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['period_till']),
      periodFrom: json['period_from'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['period_from']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period_till': periodTill?.millisecondsSinceEpoch,
      'period_from': periodFrom?.millisecondsSinceEpoch,
    };
  }

  MarketplacePeriodModel copyWith({
    DateTime? periodTill,
    DateTime? periodFrom,
  }) {
    return MarketplacePeriodModel(
      periodTill: periodTill ?? this.periodTill,
      periodFrom: periodFrom ?? this.periodFrom,
    );
  }
}
