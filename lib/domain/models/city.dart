class City {
  final String name;
  final String country = "India";

  City({
    required this.name,
  });

  static City fromJson(Map<String, dynamic> e) {
    return City(name: e['name']);
  }
}
