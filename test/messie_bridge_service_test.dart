import 'package:fluffychat/services/messie_bridge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessieBridgeProvisioningStep', () {
    test('parses display_and_wait metadata', () {
      final step = MessieBridgeProvisioningStep.fromJson({
        'type': 'display_and_wait',
        'process_id': 'proc-1',
        'step_id': 'step-1',
        'instructions': 'Scan this QR code',
        'display_and_wait': {
          'message': 'Scan this QR code',
          'data': 'qr-content',
          'type': 'qr',
          'image_url': 'https://example.com/qr.png',
        },
      });

      expect(step.isDisplayAndWait, isTrue);
      expect(step.processId, 'proc-1');
      expect(step.stepId, 'step-1');
      expect(step.message, 'Scan this QR code');
      expect(step.instructions, 'Scan this QR code');
      expect(step.data, 'qr-content');
      expect(step.dataType, 'qr');
      expect(step.imageUrl, 'https://example.com/qr.png');
    });

    test('parses user_input fields', () {
      final step = MessieBridgeProvisioningStep.fromJson({
        'type': 'user_input',
        'process_id': 'proc-2',
        'step_id': 'step-2',
        'user_input': {
          'fields': [
            {
              'id': 'phone',
              'label': 'Phone number',
              'kind': 'phone_number',
              'secret': false,
            },
          ],
        },
      });

      expect(step.isUserInput, isTrue);
      expect(step.fields, hasLength(1));
      expect(step.fields.single.id, 'phone');
      expect(step.fields.single.label, 'Phone number');
      expect(step.fields.single.kind, 'phone_number');
      expect(step.fields.single.secret, isFalse);
    });

    test('uses login_id as process fallback when process_id is absent', () {
      final step = MessieBridgeProvisioningStep.fromJson({
        'type': 'user_input',
        'login_id': 'login-1',
        'step_id': 'fi.mau.whatsapp.login.phone',
        'user_input': {
          'fields': [
            {'id': 'phone_number'},
          ],
        },
      });

      expect(step.loginId, 'login-1');
      expect(step.processId, isNull);
      expect(step.effectiveProcessId, 'login-1');
      expect(step.stepId, 'fi.mau.whatsapp.login.phone');
    });

    test('parses pairing code display_and_wait steps', () {
      final step = MessieBridgeProvisioningStep.fromJson({
        'type': 'display_and_wait',
        'login_id': 'login-2',
        'step_id': 'fi.mau.whatsapp.login.code',
        'instructions': 'Input the pairing code in the WhatsApp mobile app to log in',
        'display_and_wait': {
          'data': 'K5GQ-1P3E',
          'type': 'code',
        },
      });

      expect(step.isDisplayAndWait, isTrue);
      expect(step.effectiveProcessId, 'login-2');
      expect(step.stepId, 'fi.mau.whatsapp.login.code');
      expect(step.data, 'K5GQ-1P3E');
      expect(step.dataType, 'code');
      expect(step.instructions, contains('pairing code'));
      expect(step.isCodeDisplay, isTrue);
    });

    test('infers pairing code display from code-shaped data', () {
      final step = MessieBridgeProvisioningStep.fromJson({
        'type': 'display_and_wait',
        'login_id': 'login-3',
        'step_id': 'fi.mau.whatsapp.login.code',
        'display_and_wait': {
          'data': 'ABCD-1234',
        },
      });

      expect(step.dataType, isNull);
      expect(step.isCodeDisplay, isTrue);
    });
  });
}
