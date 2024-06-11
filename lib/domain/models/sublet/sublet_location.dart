class Location {
  String? address;
  double? latitude;
  double? longitude;

  Location(
      {required this.address, required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() {
    return {
      'address': address ?? '',
      'latitude': latitude ?? 0.0,
      'longitude': longitude ?? 0.0,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      address: map['address'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
    );
  }

  Location copyWith({
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return Location(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
