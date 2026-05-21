import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluffychat/utils/keyboard/shortcut_dispatcher.dart';
import 'package:fluffychat/utils/keyboard/shortcut_resolver.dart';
import 'package:fluffychat/widgets/fluffy_chat_app.dart';

class AppShortcuts extends StatefulWidget {
  const AppShortcuts({super.key, required this.child});

  final Widget child;

  static final bool _isMac = defaultTargetPlatform == TargetPlatform.macOS;

  @override
  State<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends State<AppShortcuts> {
  static final ShortcutResolver _resolver = ShortcutResolver();

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final dispatcher = ShortcutDispatcher.instance;
    final chat = dispatcher.chatHandler;
    final chatList = dispatcher.chatListHandler;
    final path = FluffyChatApp.router.routeInformationProvider.value.uri.path;
    final primaryPressed =
        AppShortcuts._isMac
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;
    final altPressed = HardwareKeyboard.instance.isAltPressed;
    final shiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final hasOpenChat =
        path.startsWith('/rooms/') &&
        !path.startsWith('/rooms/settings') &&
        !path.startsWith('/rooms/archive/') &&
        path.split('/').length >= 3;

    // Determine context for condition evaluation.
    final primaryFocus = FocusManager.instance.primaryFocus;
    final focusContext = primaryFocus?.context;

    // Check if a modal/dialog is on top by inspecting the focused widget's route.
    bool modalOpen = false;
    if (focusContext != null) {
      final route = ModalRoute.of(focusContext);
      if (route != null && route is! PageRoute) {
        modalOpen = true;
      }
    }

    // Check if a text field is focused.
    final textFieldFocused = primaryFocus != null &&
        primaryFocus.context != null &&
        primaryFocus.context!.widget is EditableText;

    // Check if a message has native focus (not composer, not text field).
    final messageFocused = chat != null &&
        !textFieldFocused &&
        chat.messageFocusActive;

    final handled = _resolver.resolve(
      keyState: ShortcutKeyState(
        key: event.logicalKey,
        primaryPressed: primaryPressed,
        altPressed: altPressed,
        shiftPressed: shiftPressed,
      ),
      context: ShortcutContext(
        hasOpenChat: hasOpenChat,
        textFieldFocused: textFieldFocused,
        messageFocused: messageFocused,
        modalOpen: modalOpen,
      ),
      chat: chat,
      chatList: chatList,
    );

    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: widget.child,
    );
  }
}
