import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'messie_register_view.dart';

class MessieRegister extends StatefulWidget {
  final Client client;
  const MessieRegister({required this.client, super.key});

  @override
  MessieRegisterController createState() => MessieRegisterController();
}

class MessieRegisterController extends State<MessieRegister> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? usernameError;
  String? passwordError;
  String? confirmPasswordError;
  bool loading = false;
  bool showPassword = false;

  void toggleShowPassword() =>
      setState(() => showPassword = !loading && !showPassword);

  Future<void> register() async {
    final l10n = L10n.of(context);

    if (usernameController.text.isEmpty) {
      setState(() => usernameError = l10n.pleaseEnterYourUsername);
    } else {
      setState(() => usernameError = null);
    }
    if (passwordController.text.isEmpty) {
      setState(() => passwordError = l10n.pleaseEnterYourPassword);
    } else {
      setState(() => passwordError = null);
    }
    if (confirmPasswordController.text != passwordController.text) {
      setState(() => confirmPasswordError = l10n.passwordsDoNotMatch);
    } else {
      setState(() => confirmPasswordError = null);
    }

    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text != passwordController.text) {
      return;
    }

    setState(() => loading = true);

    try {
      final client = widget.client;

      // First call to get the session
      try {
        await client.register(
          username: usernameController.text,
          password: passwordController.text,
          initialDeviceDisplayName: PlatformInfos.appDisplayName,
        );
      } on MatrixException catch (e) {
        if (e.session == null) rethrow;

        // Complete the dummy auth stage
        await client.register(
          username: usernameController.text,
          password: passwordController.text,
          initialDeviceDisplayName: PlatformInfos.appDisplayName,
          auth: AuthenticationData(
            type: AuthenticationTypes.dummy,
            session: e.session,
          ),
        );
      }

      // register() already logs in the client (sets access token + device ID)
      if (mounted) {
        context.go('/backup');
      }
    } on MatrixException catch (exception) {
      setState(() => usernameError = exception.errorMessage);
      return setState(() => loading = false);
    } catch (exception) {
      setState(() => usernameError = exception.toString());
      return setState(() => loading = false);
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => MessieRegisterView(this);
}
