class MarketplaceLinkModel {
  String? link;
  String? referenceName;

  MarketplaceLinkModel({this.link, this.referenceName});

  factory MarketplaceLinkModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceLinkModel(
      link: json['link'],
      referenceName: json['reference_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'reference_name': referenceName,
    };
  }

  // null safe copy with
  MarketplaceLinkModel copyWith({
    String? link,
    String? referenceName,
  }) {
    return MarketplaceLinkModel(
      link: link ?? this.link,
      referenceName: referenceName ?? this.referenceName,
    );
  }
}
