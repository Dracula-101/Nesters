import 'package:flutter/widgets.dart';

extension MediaDimensions on MediaQueryData {
  double get width => size.width;
  double get height => size.height;

  double get shortestSide => size.shortestSide;
  double get longestSide => size.longestSide;

  double get aspectRatio => size.aspectRatio;

  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  bool get isSmallMobile => shortestSide < 600;
  bool get isMobile => shortestSide < 800;
  bool get isTablet => shortestSide < 1200 && shortestSide >= 800;
  bool get isSmallTablet => shortestSide < 1000 && shortestSide >= 800;
  bool get isLargeTablet => shortestSide < 1600 && shortestSide >= 1200;
}
