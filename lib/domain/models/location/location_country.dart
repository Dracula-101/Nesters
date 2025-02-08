class LocationCountry {
  final String name;

  LocationCountry({required this.name});

  factory LocationCountry.fromJson(Map<String, dynamic> json) {
    return LocationCountry(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  String toString() {
    return name;
  }
}
