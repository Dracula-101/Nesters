class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  String toPoint() {
    return 'POINT($longitude $latitude)';
  }

<<<<<<< HEAD
  factory Location.fromPoint(String point) {
=======
  factory Location.fromPoint(String? point) {
    if (point == null || point.isEmpty) {
      return Location();
    }
    if (!point.startsWith('POINT')) {
      return Location();
    }
>>>>>>> 0a3916120374885fa562118e3257720de4aa4624
    final pointString = point.substring(6, point.length - 1);
    final pointArray = pointString.split(' ');
    return Location(
      latitude: double.tryParse(pointArray[1]),
      longitude: double.tryParse(pointArray[0]),
<<<<<<< HEAD
=======
    );
  }

  factory Location.fromCoords({
    required double lat,
    required double long,
  }) {
    return Location(
      latitude: lat,
      longitude: long,
>>>>>>> 0a3916120374885fa562118e3257720de4aa4624
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
