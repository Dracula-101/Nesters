import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/utils/logger/logger.dart';

extension BuildContextExtension on BuildContext {
  //logger
  AppLogger get logger => GetIt.I<AppLogger>();
}
