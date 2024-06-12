class ApartmentSize {
  int? beds;
  int? baths;

  ApartmentSize({this.beds, this.baths});

  Map<String, dynamic> toMap() {
    return {
      'beds': beds ?? 0,
      'baths': baths ?? 0,
    };
  }

  factory ApartmentSize.fromMap(Map<String, dynamic> map) {
    return ApartmentSize(
      beds: map['beds'] ?? 0,
      baths: map['baths'] ?? 0,
    );
  }

  ApartmentSize copyWith({
    int? beds,
    int? baths,
  }) {
    return ApartmentSize(
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
    );
  }
}
