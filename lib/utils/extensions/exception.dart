import 'dart:isolate';

import 'package:nesters/data/repository/utils/app_exception.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

extension ExceptionExtension on Exception {
  String get errorMessage {
    if (this is SocketException) {
      return "No internet connection. Please check your network settings.";
    } else if (this is HttpException) {
      return "Couldn't fetch data from the server. Try again later.";
    } else if (this is FormatException) {
      return "Invalid data format encountered.";
    } else if (this is TimeoutException) {
      return "The request took too long to respond. Please try again.";
    } else if (this is FileSystemException) {
      return "File operation failed. Please check file permissions.";
    } else if (this is HandshakeException) {
      return "Secure connection failed. Please check your SSL settings.";
    } else if (this is UnimplementedError) {
      return "This feature is not yet implemented.";
    } else if (this is AssertionError) {
      return "An assertion error occurred. Please report this issue.";
    } else if (this is ArgumentError) {
      return "Invalid argument provided.";
    } else if (this is RangeError) {
      return "Value is out of range.";
    } else if (this is IndexError) {
      return "Index out of bounds.";
    } else if (this is StateError) {
      return "Illegal state encountered.";
    } else if (this is IOException) {
      return "An input/output error occurred.";
    } else if (this is MissingPluginException) {
      return "A required plugin is missing.";
    } else if (this is IsolateSpawnException) {
      return "Failed to spawn a new isolate.";
    } else if (this is PlatformException) {
      return "A platform-specific error occurred.";
    } else if (this is JsonUnsupportedObjectError) {
      return "Invalid JSON data structure.";
    } else if (this is TlsException) {
      return "TLS error encountered. Check your security settings.";
    } else if (this is UnsupportedError) {
      return "This operation is not supported.";
    } else if (this is ProcessException) {
      return "A system process failed to execute.";
    } else {
      return "An unknown error occurred.";
    }
  }

  String get errorCode {
    if (this is SocketException) {
      return "ERR_INTERNET_DISCONNECTED";
    } else if (this is HttpException) {
      return "ERR_SERVER_UNREACHABLE";
    } else if (this is FormatException) {
      return "ERR_INVALID_DATA_FORMAT";
    } else if (this is TimeoutException) {
      return "ERR_REQUEST_TIMEOUT";
    } else if (this is FileSystemException) {
      return "ERR_FILE_OPERATION_FAILED";
    } else if (this is HandshakeException) {
      return "ERR_SECURE_CONNECTION_FAILED";
    } else if (this is UnimplementedError) {
      return "ERR_NOT_IMPLEMENTED";
    } else if (this is AssertionError) {
      return "ERR_ASSERTION_FAILED";
    } else if (this is ArgumentError) {
      return "ERR_INVALID_ARGUMENT";
    } else if (this is RangeError) {
      return "ERR_VALUE_OUT_OF_RANGE";
    } else if (this is IndexError) {
      return "ERR_INDEX_OUT_OF_BOUNDS";
    } else if (this is StateError) {
      return "ERR_ILLEGAL_STATE";
    } else if (this is IOException) {
      return "ERR_IO_ERR";
    } else if (this is MissingPluginException) {
      return "ERR_MISSING_PLUGIN";
    } else if (this is IsolateSpawnException) {
      return "ERR_ISOLATE_SPAWN_FAILED";
    } else if (this is PlatformException) {
      return "ERR_PLATFORM_ERR";
    } else if (this is JsonUnsupportedObjectError) {
      return "ERR_INVALID_JSON_DATA";
    } else if (this is TlsException) {
      return "ERR_TLS_ERR";
    } else if (this is UnsupportedError) {
      return "ERR_OPERATION_NOT_SUPPORTED";
    } else if (this is ProcessException) {
      return "ERR_PROCESS_FAILED";
    } else {
      return "ERR_UNKNOWN_ERR";
    }
  }

  String get getException {
    final errorMessage = toString();
    try {
      final startIndex = errorMessage.indexOf("(");
      final endIndex = errorMessage.indexOf(")");
      return errorMessage.substring(startIndex + 1, endIndex);
    } catch (e) {
      return 'Exception';
    }
  }
}
