import 'package:flutter/material.dart';
import 'package:nesters/screens/login_screen/login_screen.dart';
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
      debugShowCheckedModeBanner: false,
      navigatorKey: RootApp.navigatorKey,
      scaffoldMessengerKey: RootApp.scaffoldKey,
      title: 'Nesters',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
