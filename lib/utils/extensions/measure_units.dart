extension ImperialUnits on double {
  double get inches => this * 39.3701;
  double get feet => this * 3.28084;
  double get yards => this * 1.09361;
  double get miles => this / 1609.34;

  num get roundMiles {
    final miles = this / 1609.34;
    if (miles < 1) {
      return double.parse(miles.toStringAsFixed(2));
    } else {
      return miles.toInt();
    }
  }
}

extension MetricUnits on double {
  double get millimeters => this * 1000;
  double get centimeters => this * 100;
  double get meters => this;
  double get kilometers => this / 1000;
}
