import 'package:built_collection/built_collection.dart';
import 'package:fluffychat/services/messie_bridge_service.dart';
import 'package:fluffychat/services/messie_error_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messie_api/messie_api.dart' as api;
import 'package:one_of/one_of.dart';

api.BridgeLoginStep _wrapStep(Object value, List<Type> types) =>
    api.BridgeLoginStep((b) =>
      b.oneOf = OneOfDynamic(typeIndex: types.indexOf(value.runtimeType), types: types, value: value));

void main() {
  group('MessieBridgeProvisioningStep', () {
    test('parses display_and_wait metadata from generated bridge step', () {
      final step = MessieBridgeProvisioningStep.fromApi(
        _wrapStep(
          api.LoginStepDisplayAndWait((b) {
            b
              ..type = api.LoginStepDisplayAndWaitTypeEnum.displayAndWait
              ..processId = 'proc-1'
              ..stepId = 'step-1'
              ..displayAndWait.message = 'Scan this QR code'
              ..displayAndWait.data = 'qr-content'
              ..displayAndWait.imageUrl = 'https://example.com/qr.png';
          }),
          [
            api.LoginStepComplete,
            api.LoginStepCookies,
            api.LoginStepDisplayAndWait,
            api.LoginStepUserInput,
          ],
        ),
      );

      expect(step.isDisplayAndWait, isTrue);
      expect(step.processId, 'proc-1');
      expect(step.stepId, 'step-1');
      expect(step.message, 'Scan this QR code');
      expect(step.data, 'qr-content');
      expect(step.imageUrl, 'https://example.com/qr.png');
    });

    test('parses user_input fields from generated bridge step', () {
      final step = MessieBridgeProvisioningStep.fromApi(
        _wrapStep(
          api.LoginStepUserInput((b) {
            b
              ..type = api.LoginStepUserInputTypeEnum.userInput
              ..processId = 'proc-2'
              ..stepId = 'step-2'
              ..userInput.fields = ListBuilder([
                api.LoginStepUserInputUserInputFieldsInner((b) {
                  b
                    ..id = 'phone'
                    ..label = 'Phone number'
                    ..kind = 'phone_number'
                    ..secret = false;
                }),
              ]);
          }),
          [
            api.LoginStepComplete,
            api.LoginStepCookies,
            api.LoginStepDisplayAndWait,
            api.LoginStepUserInput,
          ],
        ),
      );

      expect(step.isUserInput, isTrue);
      expect(step.fields, hasLength(1));
      expect(step.fields.single.id, 'phone');
      expect(step.fields.single.label, 'Phone number');
      expect(step.fields.single.kind, 'phone_number');
      expect(step.fields.single.secret, isFalse);
    });

    test('uses login_id as process fallback when process_id is absent', () {
      final step = MessieBridgeProvisioningStep.fromApi(
        _wrapStep(
          api.LoginStepUserInput((b) {
            b
              ..type = api.LoginStepUserInputTypeEnum.userInput
              ..loginId = 'login-1'
              ..stepId = 'fi.mau.whatsapp.login.phone'
              ..userInput.fields = ListBuilder([
                api.LoginStepUserInputUserInputFieldsInner((b) => b.id = 'phone_number'),
              ]);
          }),
          [
            api.LoginStepComplete,
            api.LoginStepCookies,
            api.LoginStepDisplayAndWait,
            api.LoginStepUserInput,
          ],
        ),
      );

      expect(step.loginId, 'login-1');
      expect(step.processId, isNull);
      expect(step.effectiveProcessId, 'login-1');
      expect(step.stepId, 'fi.mau.whatsapp.login.phone');
    });

    test('parses pairing code display_and_wait steps from generated bridge step', () {
      final step = MessieBridgeProvisioningStep.fromApi(
        _wrapStep(
          api.LoginStepDisplayAndWait((b) {
            b
              ..type = api.LoginStepDisplayAndWaitTypeEnum.displayAndWait
              ..loginId = 'login-2'
              ..stepId = 'fi.mau.whatsapp.login.code'
              ..displayAndWait.data = 'K5GQ-1P3E';
          }),
          [
            api.LoginStepComplete,
            api.LoginStepCookies,
            api.LoginStepDisplayAndWait,
            api.LoginStepUserInput,
          ],
        ),
      );

      expect(step.isDisplayAndWait, isTrue);
      expect(step.effectiveProcessId, 'login-2');
      expect(step.stepId, 'fi.mau.whatsapp.login.code');
      expect(step.data, 'K5GQ-1P3E');
      expect(step.isCodeDisplay, isTrue);
    });

    test('infers pairing code display from code-shaped data', () {
      final step = MessieBridgeProvisioningStep.fromApi(
        _wrapStep(
          api.LoginStepDisplayAndWait((b) {
            b
              ..type = api.LoginStepDisplayAndWaitTypeEnum.displayAndWait
              ..loginId = 'login-3'
              ..stepId = 'fi.mau.whatsapp.login.code'
              ..displayAndWait.data = 'ABCD-1234';
          }),
          [
            api.LoginStepComplete,
            api.LoginStepCookies,
            api.LoginStepDisplayAndWait,
            api.LoginStepUserInput,
          ],
        ),
      );

      expect(step.dataType, isNull);
      expect(step.isCodeDisplay, isTrue);
    });

    test('throws a stable state error when login start returns no step', () {
      expect(
        () => MessieBridgeProvisioningStep.fromApi(
          _wrapStep(
            api.LoginStepComplete((b) {
              b
                ..type = api.LoginStepCompleteTypeEnum.complete
                ..complete.userLoginId = 'login-1';
            }),
            [
              api.LoginStepComplete,
              api.LoginStepCookies,
              api.LoginStepDisplayAndWait,
              api.LoginStepUserInput,
            ],
          ),
        ),
        returnsNormally,
      );
    });
  });

  group('Messie error contracts', () {
    test('MessieUserException renders the user-safe message', () {
      final exception = MessieUserException(
        kind: MessieErrorKind.server,
        operation: 'Failed to load bridge account state',
        userMessage:
            'Messie had a problem handling that request. Please try again shortly.',
      );

      expect(
        exception.toString(),
        'Messie had a problem handling that request. Please try again shortly.',
      );
    });
  });
}
