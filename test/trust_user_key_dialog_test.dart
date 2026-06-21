import 'package:fluffychat/pages/chat/trust_user_key_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('skip trust prompt when no keys are available', () {
    expect(
      shouldSkipTrustPromptForMasterKey(
        hasKeys: false,
        hasMasterKey: false,
        verified: false,
      ),
      isTrue,
    );
  });

  test('skip trust prompt when master key is already verified', () {
    expect(
      shouldSkipTrustPromptForMasterKey(
        hasKeys: true,
        hasMasterKey: true,
        verified: true,
      ),
      isTrue,
    );
  });

  test('show trust prompt for unverified untrusted master key', () {
    expect(
      shouldSkipTrustPromptForMasterKey(
        hasKeys: true,
        hasMasterKey: true,
        verified: false,
      ),
      isFalse,
    );
  });
}
