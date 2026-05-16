import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/widgets/layouts/login_scaffold.dart';
import 'package:flutter/material.dart';

import 'messie_register.dart';

class MessieRegisterView extends StatelessWidget {
  final MessieRegisterController controller;

  const MessieRegisterView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final homeserver = controller.widget.client.homeserver
        ?.toString()
        .replaceFirst('https://', '')
        .replaceFirst('http://', '');

    return LoginScaffold(
      appBar: AppBar(
        leading: controller.loading ? null : const Center(child: BackButton()),
        automaticallyImplyLeading: !controller.loading,
        titleSpacing: !controller.loading ? 0 : null,
        title: Text(L10n.of(context).createNewAccount),
      ),
      body: Builder(
        builder: (context) {
          return AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: <Widget>[
                Hero(
                  tag: 'info-logo',
                  child: Image.asset('assets/banner_transparent.png'),
                ),
                const SizedBox(height: 16),
                if (homeserver != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Register on $homeserver',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    readOnly: controller.loading,
                    autocorrect: false,
                    autofocus: true,
                    controller: controller.usernameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    autofillHints: controller.loading
                        ? null
                        : [AutofillHints.newUsername],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.account_box_outlined),
                      errorText: controller.usernameError,
                      errorStyle: const TextStyle(color: Colors.orange),
                      hintText: 'username',
                      labelText: L10n.of(context).username,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    readOnly: controller.loading,
                    autocorrect: false,
                    autofillHints: controller.loading
                        ? null
                        : [AutofillHints.newPassword],
                    controller: controller.passwordController,
                    textInputAction: TextInputAction.next,
                    obscureText: !controller.showPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outlined),
                      errorText: controller.passwordError,
                      errorStyle: const TextStyle(color: Colors.orange),
                      suffixIcon: IconButton(
                        onPressed: controller.toggleShowPassword,
                        icon: Icon(
                          controller.showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black,
                        ),
                      ),
                      hintText: '******',
                      labelText: L10n.of(context).password,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    readOnly: controller.loading,
                    autocorrect: false,
                    autofillHints: controller.loading
                        ? null
                        : [AutofillHints.newPassword],
                    controller: controller.confirmPasswordController,
                    textInputAction: TextInputAction.go,
                    obscureText: !controller.showPassword,
                    onSubmitted: (_) => controller.register(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outlined),
                      errorText: controller.confirmPasswordError,
                      errorStyle: const TextStyle(color: Colors.orange),
                      hintText: '******',
                      labelText: L10n.of(context).repeatPassword,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: controller.loading ? null : controller.register,
                    child: controller.loading
                        ? const LinearProgressIndicator()
                        : Text(L10n.of(context).createNewAccount),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
