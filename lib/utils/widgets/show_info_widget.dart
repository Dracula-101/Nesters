import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/theme/theme.dart';

class ShowInfoWidget extends StatelessWidget {
  final String message;
  final String subtitle;
  final IconData? icon;
  const ShowInfoWidget(
      {super.key, required this.message, required this.subtitle, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.info_outline_rounded,
              color: AppTheme.primaryShades.shade300,
              size: 90,
            ),
            Text(
              message,
              style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
