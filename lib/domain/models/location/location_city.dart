class LocationCity {
  final String name;

  LocationCity({
    required this.name,
  });

  static LocationCity fromJson(Map<String, dynamic> e) {
    return LocationCity(name: e['name']);
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
