import 'package:flutter/material.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/theme/theme.dart';

class ErrorUserProfile extends StatelessWidget {
  final AppException error;
  const ErrorUserProfile({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 120,
            ),
            const SizedBox(height: 8),
            Text(
              "Error",
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              error.message,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
