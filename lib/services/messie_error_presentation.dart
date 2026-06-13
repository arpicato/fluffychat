import 'package:fluffychat/services/messie_error_service.dart';

String messieUserMessage(
  Object? error, {
  required String fallback,
}) {
  if (error is MessieUserException) {
    return error.userMessage;
  }
  return fallback;
}
