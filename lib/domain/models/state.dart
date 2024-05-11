class CountryState {
  final String id;
  final String name;

  CountryState({required this.name, required this.id});

  factory CountryState.fromJson(Map<String, dynamic> json) {
    return CountryState(
      id: json['id'],
      name: json['name'],
    );
  }
}
