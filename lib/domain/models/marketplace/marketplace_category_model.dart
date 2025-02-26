class MarketplaceCategoryModel {
  int? id;
  String? name;

  MarketplaceCategoryModel({this.id, this.name});

  factory MarketplaceCategoryModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategoryModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  //null safe copywith
  MarketplaceCategoryModel copyWith({
    int? id,
    String? name,
  }) {
    return MarketplaceCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return name ?? '';
  }
}
