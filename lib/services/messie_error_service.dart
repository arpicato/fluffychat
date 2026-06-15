import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';

enum MessieErrorKind {
  timeout,
  network,
  unauthorized,
  forbidden,
  notFound,
  rateLimited,
  server,
  invalidResponse,
  unknown,
}

class MessieUserException implements Exception {
  MessieUserException({
    required this.kind,
    required this.userMessage,
    required this.operation,
  });

  final MessieErrorKind kind;
  final String userMessage;
  final String operation;

  @override
  String toString() => userMessage;
}

class MessieLogService {
  MessieLogService._();

  static final MessieLogService instance = MessieLogService._();

  static const _logFileName = 'messie-client.log';
  static const _maxBytes = 512 * 1024;
  static const _maxRotatedFiles = 3;

  bool get _isTestEnvironment =>
      Platform.environment.containsKey('FLUTTER_TEST') ||
      Platform.environment.containsKey('DART_TEST');

  Future<File> _logFile() async {
    if (_isTestEnvironment || PlatformDispatcher.instance.implicitView == null) {
      final directory = Directory('/tmp/opencode');
      await directory.create(recursive: true);
      return File('${directory.path}/$_logFileName');
    }
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_logFileName');
  }

  Future<void> write(
    String scope,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    try {
      final file = await _logFile();
      await file.parent.create(recursive: true);
      if (await file.exists()) {
        final stat = await file.stat();
        if (stat.size >= _maxBytes) {
          await _rotate(file);
        }
      }
      final buffer = StringBuffer()
        ..write(DateTime.now().toUtc().toIso8601String())
        ..write(' [')
        ..write(scope)
        ..write('] ')
        ..write(message);
      if (error != null) {
        buffer
          ..write(' | error=')
          ..write(error);
      }
      if (stackTrace != null) {
        buffer
          ..write('\n')
          ..write(stackTrace);
      }
      buffer.write('\n');
      final line = buffer.toString();
      if (kIsWeb) {
        // Mirror retained Messie diagnostics to the browser console so web
        // debugging sees the same service-specific signal as the persisted log.
        Logs().w(line.trimRight());
      }
      await file.writeAsString(line, mode: FileMode.append);
    } catch (e, s) {
      Logs().w('[messie/log] failed to write client log', e, s);
    }
  }

  Future<void> _rotate(File file) async {
    for (var i = _maxRotatedFiles - 1; i >= 1; i--) {
      final older = File('${file.path}.$i');
      final newer = File('${file.path}.${i + 1}');
      if (await older.exists()) {
        if (i + 1 > _maxRotatedFiles) {
          await older.delete();
        } else {
          await older.rename(newer.path);
        }
      }
    }
    if (await file.exists()) {
      await file.rename('${file.path}.1');
    }
  }
}

class MessieErrorService {
  const MessieErrorService();

  MessieUserException httpFailure(
    String operation,
    int statusCode,
    String body,
  ) {
    final serverMessage = _extractServerMessage(body);
    return _mapError(
      operation,
      statusCode,
      DioExceptionType.badResponse,
      serverMessage,
    );
  }

  String _extractServerMessage(Object? data) {
    if (data == null) return '';
    if (data is List<int>) {
      try {
        return _extractServerMessage(utf8.decode(data));
      } catch (_) {
        return data.toString();
      }
    }
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('<!DOCTYPE html>') || trimmed.startsWith('<html')) {
        return '';
      }
      return trimmed;
    }
    if (data is Map) {
      final message =
          data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString();
      return message?.trim() ?? '';
    }
    try {
      final encoded = jsonEncode(data);
      if (encoded.startsWith('"<!DOCTYPE html>') || encoded.startsWith('"<html')) {
        return '';
      }
      return encoded;
    } catch (_) {
      return data.toString();
    }
  }

  String _normalizeServerMessage(String message) {
    const calendarImportPrefix = 'Failed to import calendar source: ';
    if (message.startsWith(calendarImportPrefix)) {
      return message.substring(calendarImportPrefix.length).trim();
    }
    return message;
  }

  Future<MessieUserException> fromDio(
    String scope,
    String operation,
    DioException error,
  ) async {
    final statusCode = error.response?.statusCode;
    final innerError = error.error;
    final serverMessage = _normalizeServerMessage(
      _extractServerMessage(error.response?.data),
    );
    final detail = [
      if (statusCode != null) 'status=$statusCode',
      'type=${error.type.name}',
      if (serverMessage.isNotEmpty) 'server=$serverMessage',
      if (error.message?.isNotEmpty == true) 'dio=${error.message}',
      if (innerError != null) 'inner=$innerError',
    ].join(' | ');
    await MessieLogService.instance.write(
      scope,
      operation,
      error: detail,
      stackTrace: error.stackTrace,
    );
    if (innerError is TimeoutException) {
      return MessieUserException(
        kind: MessieErrorKind.timeout,
        operation: operation,
        userMessage: 'Unable to reach Messie right now. Check your connection and try again.',
      );
    }
    return _mapError(operation, statusCode, error.type, serverMessage);
  }

  Future<MessieUserException> fromGeneric(
    String scope,
    String operation,
    Object error,
    StackTrace stackTrace,
  ) async {
    await MessieLogService.instance.write(
      scope,
      operation,
      error: error,
      stackTrace: stackTrace,
    );
    if (error is TimeoutException) {
      return MessieUserException(
        kind: MessieErrorKind.timeout,
        operation: operation,
        userMessage: 'The request timed out. Please try again.',
      );
    }
    if (error is IOException || error is SocketException) {
      return MessieUserException(
        kind: MessieErrorKind.network,
        operation: operation,
        userMessage: 'Unable to reach Messie right now. Check your connection and try again.',
      );
    }
    return MessieUserException(
      kind: MessieErrorKind.unknown,
      operation: operation,
      userMessage: 'Something went wrong while talking to Messie. Please try again.',
    );
  }

  MessieUserException _mapError(
    String operation,
    int? statusCode,
    DioExceptionType type,
    String serverMessage,
  ) {
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return MessieUserException(
        kind: MessieErrorKind.timeout,
        operation: operation,
        userMessage: 'Messie took too long to respond. Please try again.',
      );
    }
    if (type == DioExceptionType.connectionError ||
        type == DioExceptionType.badCertificate ||
        type == DioExceptionType.unknown) {
      return MessieUserException(
        kind: MessieErrorKind.network,
        operation: operation,
        userMessage: 'Unable to reach Messie right now. Check your connection and try again.',
      );
    }
    switch (statusCode) {
      case 401:
        return MessieUserException(
          kind: MessieErrorKind.unauthorized,
          operation: operation,
          userMessage: 'Your Messie session expired. Please sign in again.',
        );
      case 403:
        return MessieUserException(
          kind: MessieErrorKind.forbidden,
          operation: operation,
          userMessage: 'You do not have permission to do that in Messie.',
        );
      case 404:
        return MessieUserException(
          kind: MessieErrorKind.notFound,
          operation: operation,
          userMessage: 'That item could not be found in Messie anymore.',
        );
      case 408:
      case 504:
        return MessieUserException(
          kind: MessieErrorKind.timeout,
          operation: operation,
          userMessage: 'Messie took too long to respond. Please try again.',
        );
      case 429:
        return MessieUserException(
          kind: MessieErrorKind.rateLimited,
          operation: operation,
          userMessage: 'Messie is receiving too many requests right now. Please wait a moment and try again.',
        );
    }
    if (statusCode != null && statusCode >= 500) {
      return MessieUserException(
        kind: MessieErrorKind.server,
        operation: operation,
        userMessage: 'Messie had a problem handling that request. Please try again shortly.',
      );
    }
    if (serverMessage.isNotEmpty && !_looksLikeHtml(serverMessage)) {
      return MessieUserException(
        kind: MessieErrorKind.invalidResponse,
        operation: operation,
        userMessage: serverMessage,
      );
    }
    return MessieUserException(
      kind: MessieErrorKind.unknown,
      operation: operation,
      userMessage: 'Something went wrong while talking to Messie. Please try again.',
    );
  }

  bool _looksLikeHtml(String value) {
    final trimmed = value.trimLeft();
    return trimmed.startsWith('<!DOCTYPE html>') || trimmed.startsWith('<html');
  }
}
