import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffychat/services/messie_error_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = MessieErrorService();

  test('maps Dio timeout failures to a timeout user message', () async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/calendar/events'),
      type: DioExceptionType.connectionTimeout,
    );

    final result = await service.fromDio(
      'messie/test',
      'Load calendar',
      error,
    );

    expect(result.kind, MessieErrorKind.timeout);
    expect(result.userMessage, 'Messie took too long to respond. Please try again.');
  });

  test('maps backend 401 failures to a sign-in-again message', () async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/auth/matrix/openid'),
      response: Response(
        requestOptions: RequestOptions(path: '/auth/matrix/openid'),
        statusCode: 401,
        data: {'message': 'expired token'},
      ),
      type: DioExceptionType.badResponse,
    );

    final result = await service.fromDio(
      'messie/test',
      'Backend session',
      error,
    );

    expect(result.kind, MessieErrorKind.unauthorized);
    expect(result.userMessage, 'Your Messie session expired. Please sign in again.');
  });

  test('suppresses raw html fallback pages in user-facing messages', () {
    final result = service.httpFailure(
      'Load calendar',
      502,
      '<!DOCTYPE html><html><body>proxy error</body></html>',
    );

    expect(result.kind, MessieErrorKind.server);
    expect(
      result.userMessage,
      'Messie had a problem handling that request. Please try again shortly.',
    );
  });

  test('writes test-mode logs to /tmp/opencode fallback', () async {
    final file = File('/tmp/opencode/messie-client.log');
    if (await file.exists()) {
      await file.delete();
    }

    await MessieLogService.instance.write(
      'messie/test',
      'Synthetic failure',
      error: 'detail',
    );

    expect(await file.exists(), isTrue);
    final contents = await file.readAsString();
    expect(contents, contains('[messie/test] Synthetic failure | error=detail'));
    expect(contents, endsWith('\n'));
  });

  test('maps generic IO failures to a network message', () async {
    final result = await service.fromGeneric(
      'messie/test',
      'Load todos',
      const SocketException('connection refused'),
      StackTrace.current,
    );

    expect(result.kind, MessieErrorKind.network);
    expect(
      result.userMessage,
      'Unable to reach Messie right now. Check your connection and try again.',
    );
  });

  test('maps generic timeout failures to a timeout message', () async {
    final result = await service.fromGeneric(
      'messie/test',
      'Load todos',
      TimeoutException('timed out'),
      StackTrace.current,
    );

    expect(result.kind, MessieErrorKind.timeout);
    expect(result.userMessage, 'The request timed out. Please try again.');
  });
}
