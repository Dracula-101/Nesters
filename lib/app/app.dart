import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RootApp.navigatorKey,
      scaffoldMessengerKey: RootApp.scaffoldKey,
      title: 'Nesters',
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Text(
          'Hello World!',
          style: AppTheme.headlineSmall,
        );
      },
    );
  }
}
