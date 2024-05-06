part of 'extensions.dart';

extension TimerExtension on Future<void> {
  Future<int> get timeInMilliseconds async {
    final stopwatch = Stopwatch()..start();
    await this;
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }
}
