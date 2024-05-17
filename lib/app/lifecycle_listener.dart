import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/utils/logger/logger.dart';

class LifecycleListener extends StatefulWidget {
  final Widget child;
  const LifecycleListener({super.key, required this.child});

  @override
  State<LifecycleListener> createState() => _LifecycleListenerState();
}

class _LifecycleListenerState extends State<LifecycleListener>
    with WidgetsBindingObserver {
  final AppLoggerService _appLoggerService = GetIt.I<AppLoggerService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add the observer
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _appLoggerService.info('App resumed');
        break;
      case AppLifecycleState.inactive:
        _appLoggerService.info('App inactive (Android)');
        break;
      case AppLifecycleState.paused:
        _appLoggerService.info('App paused');
        break;
      case AppLifecycleState.detached:
        _appLoggerService.info('App detached');
        break;
      case AppLifecycleState.hidden:
        _appLoggerService.info('App hidden (iOS)');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
