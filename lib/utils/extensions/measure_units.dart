extension ImperialUnits on double {
  double get inches => this * 39.3701;
  double get feet => this * 3.28084;
  double get yards => this * 1.09361;
  double get miles => this / 1609.34;

  String get formattedMiles {
    final miles = this / 1609.34;
    if (miles < 0.1) {
      return '${(miles * 5280).toInt()} ft';
    } else if (miles < 1) {
      return '${miles.toStringAsFixed(2)} mi';
    } else {
      return '${miles.toInt()} mi';
    }
  }
}

extension MetricUnits on double {
  double get millimeters => this * 1000;
  double get centimeters => this * 100;
  double get meters => this;
  double get kilometers => this / 1000;
}
