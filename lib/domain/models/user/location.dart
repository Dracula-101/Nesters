class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  String toPoint() {
    return 'POINT($longitude $latitude)';
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    // check for point
    if (map['location'] != null && map['location'] is String) {
      final point = map['location'] as String;
      if (point.startsWith('POINT(') && point.endsWith(')')) {
        final coords = point.substring(6, point.length - 1).split(' ');
        if (coords.length == 2) {
          return Location(
            latitude: double.parse(coords[1]),
            longitude: double.parse(coords[0]),
          );
        }
      }
    }
    if (map['latitude'] != null && map['longitude'] != null) {
      return Location(
        latitude: map['latitude'] as double,
        longitude: map['longitude'] as double,
      );
    }
    return Location();
  }

  factory Location.fromCoords({
    required double lat,
    required double long,
  }) {
    return Location(
      latitude: lat,
      longitude: long,
    );
  }

  Location copyWith({
    double? latitude,
    double? longitude,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
