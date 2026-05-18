import 'package:flutter/widgets.dart';

/// All keyboard shortcut intents for the app.
/// Kept in one file to minimize upstream merge conflicts.

// -- Global navigation --
class SearchIntent extends Intent {
  const SearchIntent();
}

class NewChatIntent extends Intent {
  const NewChatIntent();
}

class SettingsIntent extends Intent {
  const SettingsIntent();
}

class GoBackIntent extends Intent {
  const GoBackIntent();
}

// -- Chat list navigation --
class ChatListFocusUpIntent extends Intent {
  const ChatListFocusUpIntent();
}

class ChatListFocusDownIntent extends Intent {
  const ChatListFocusDownIntent();
}

class ChatListOpenFocusedIntent extends Intent {
  const ChatListOpenFocusedIntent();
}

// -- Message list navigation --
class MessageFocusUpIntent extends Intent {
  const MessageFocusUpIntent();
}

class MessageFocusDownIntent extends Intent {
  const MessageFocusDownIntent();
}

class MessageReplyIntent extends Intent {
  const MessageReplyIntent();
}

class MessageEditIntent extends Intent {
  const MessageEditIntent();
}

class MessageDeselectIntent extends Intent {
  const MessageDeselectIntent();
}
