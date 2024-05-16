class City {
  final String name;
  final String country = "India";

  City({
    required this.name,
  });

  static City fromJson(Map<String, dynamic> e) {
    return City(name: e['name']);
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
