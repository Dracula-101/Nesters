class LocationState {
  final String name;

  LocationState({required this.name});

  factory LocationState.fromJson(Map<String, dynamic> json) {
    return LocationState(
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
