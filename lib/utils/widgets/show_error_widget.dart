import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nesters/data/repository/database/remote/error/database_error.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/theme/theme.dart';

class ShowErrorWidget extends StatelessWidget {
  final String? message;
  final Exception? error;
  const ShowErrorWidget({super.key, this.error, this.message});

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
              Icons.error,
              color: AppTheme.error,
              size: 90,
            ),
            Text(
              message != null
                  ? "Error"
                  : (error is NoNetworkError)
                      ? "Network Issue"
                      : (error is DatabaseError)
                          ? 'Server Error'
                          : (error is SocketException)
                              ? 'Network Issue'
                              : (error is TimeoutException)
                                  ? 'Time Out'
                                  : (error is FormatException)
                                      ? 'Invalid Response'
                                      : (error is HttpException)
                                          ? 'Server Error'
                                          : (error is FileSystemException)
                                              ? 'File system error'
                                              : (error is AppException)
                                                  ? "App error"
                                                  : 'Error',
              style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message != null
                  ? message!
                  : (error is AppException)
                      ? (error as AppException).message
                      : (error is SocketException)
                          ? 'Please check your internet connection and try again'
                          : 'Please try again later',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
