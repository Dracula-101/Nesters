import 'package:logger/logger.dart';

class LoggerService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2, // number of method calls to be displayed
        errorMethodCount: 8, // number of method calls if stacktrace is provided
        lineLength: 120, // width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        printTime: false // Should each log print contain a timestamp
        ),
  );

  void info(Object? message) {
    _logger.i(message);
  }

  void error(Object? message) {
    _logger.e(message);
  }

  void warning(Object? message) {
    _logger.w(message);
  }

  void debug(Object? message) {
    _logger.d(message);
  }
}
