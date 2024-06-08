import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/theme/theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashView(),
    );
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.personShelter,
              size: 120,
              color: AppTheme.background,
            ),
            const SizedBox(height: 20),
            Text(
              'Nesters',
              style:
                  AppTheme.headlineLarge.copyWith(color: AppTheme.background),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const SizedBox(
                width: 100,
                height: 3,
                child: LinearProgressIndicator(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
