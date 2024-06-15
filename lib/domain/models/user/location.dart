class Location {
  String? address;
  double? latitude;
  double? longitude;

  Location({this.address, this.latitude, this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'address': address ?? '',
      'latitude': latitude ?? 0.0,
      'longitude': longitude ?? 0.0,
    };
  }

  factory Location.fromJson(Map<String, dynamic> map) {
    return Location(
      address: map['address'] ?? '',
      latitude: double.tryParse(map['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(map['longitude'].toString()) ?? 0.0,
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
