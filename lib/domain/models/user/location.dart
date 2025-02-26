class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  String toPoint() {
    return 'POINT($longitude $latitude)';
  }

  factory Location.fromPoint(String point) {
    final pointString = point.substring(6, point.length - 1);
    final pointArray = pointString.split(' ');
    return Location(
      latitude: double.tryParse(pointArray[1]),
      longitude: double.tryParse(pointArray[0]),
    );
  }

  Location copyWith({
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
