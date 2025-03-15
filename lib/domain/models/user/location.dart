class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  String toPoint() {
    return 'POINT($longitude $latitude)';
  }

  factory Location.fromPoint(String? point) {
    if (point == null || point.isEmpty) {
      return Location();
    }
    if (!point.startsWith('POINT')) {
      return Location();
    }
    final pointString = point.substring(6, point.length - 1);
    final pointArray = pointString.split(' ');
    return Location(
      latitude: double.tryParse(pointArray[1]),
      longitude: double.tryParse(pointArray[0]),
    );
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
