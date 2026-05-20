# TEMP Keyboard Shortcuts Plan

Delete this file after the keyboard shortcut architecture and UX changes are implemented.

## Goals

- Keep keyboard shortcut work upstream-friendly for as long as possible.
- Move toward a focus-aware global shortcut resolver, similar to VS Code.
- Unify keyboard message navigation with existing message selection UX instead of maintaining a parallel long-term model.
- Make shortcuts discoverable and eventually configurable.

## Architecture Direction

- Keep the main keyboard system isolated under `lib/utils/keyboard/` as much as possible.
- Prefer a central shortcut registry and resolver over spreading more logic across page-local Flutter `Actions` trees.
- Keep page-level integration thin:
  - chat list registers a small command adapter
  - chat page registers a small command adapter
- Avoid growing keyboard-specific logic directly inside large upstream-sensitive files like `chat.dart` and `chat_list.dart` beyond minimal adapters.

## Planned Structure

- `ShortcutRegistry`
  - owns command IDs
  - owns default bindings
  - provides human-readable labels for help UI
- `ShortcutResolver`
  - receives raw key events globally
  - checks route, focus, and page context
  - dispatches command IDs to active handlers
- `ShortcutContext`
  - current route
  - whether a chat is open
  - whether composer is focused
  - composer cursor position
  - whether a message is highlighted
  - whether one or more messages are toggled selected
  - whether search/settings/modal state is active
- `ShortcutHandlers`
  - thin interfaces/adapters implemented by chat list and chat page
- `ShortcutSettings`
  - future storage for user-customizable bindings
- `ShortcutHelpModel`
  - registry-backed source for shortcut hint popup content

## Message Focus vs Selection

- Distinguish between:
  - highlighted message
  - toggled selected messages
- Arrow keys should move the highlighted message.
- Actions like reply/edit should work on the highlighted message even if nothing is toggled selected.
- This means keyboard users do not need to toggle a message first to act on it.

## Selection UX

- `Space` toggles the currently highlighted message in/out of selection.
- Do not require `Ctrl+Space` for toggle.
- `Shift+Arrow` should extend/shrink selection range from an anchor, similar to desktop list/text selection behavior.
- Plain arrows should move highlight without automatically destroying existing multi-selection.
- `Escape` should clear selection/highlight state before broader navigation.

## Multi-Select Behavior

- Keep an explicit selection anchor for range operations.
- If multiple messages are selected:
  - plain arrows move highlight
  - `Shift+Arrow` modifies the selected range
  - `Space` toggles the highlighted item
- Actions with one obvious target:
  - reply/edit use highlighted message when no messages are toggled selected
- Actions that are inherently multi-item:
  - forward/delete/redact operate on toggled selected set

## Checkbox UX

- Hide checkbox circles until at least one message is actually toggled selected.
- While only a highlighted message exists, UI should read as:
  - "keyboard focus/highlight"
  - not "selection mode"
- Once at least one message is toggled selected, show checkboxes and selection affordances.
- This should make keyboard and mouse semantics clearer:
  - highlighted message = current target
  - toggled message(s) = selected set for batch actions

## Composer / Arrow Behavior

- When no chat is open:
  - plain `Up/Down` move chat list highlight
- When chat is open:
  - plain `Up` from composer should enter highlighted-message navigation when:
    - composer is not focused, or
    - composer focus is on the first line / top boundary
  - plain `Down` should move back toward composer and eventually return focus to input
- `Escape` in chat should behave in this order:
  - clear message range selection
  - clear highlighted message mode
  - cancel reply/edit target
  - close thread/details context if active
  - close chat if appropriate

## Open Actions

- Opening a chat from keyboard should focus the composer by default.
- Reply/edit shortcut should not require toggled selection first.
- Selected/highlighted message should auto-scroll into view during keyboard navigation.

## Shortcut Help Popup

- Add a keyboard shortcuts hint popup button.
- Do not hard-code shortcut labels in UI.
- Render popup contents from the registry so it automatically reflects current bindings.

## Configurability

- Do not hard-code business logic around literal key combos deeper than the registry/resolver layer.
- Bindings should be represented as command-to-shortcut mappings.
- Future settings UI should be able to read and overwrite those mappings without changing command behavior.

## Upstream Compatibility Guidance

- Prefer adding new keyboard-specific files over deeply editing existing upstream-heavy files.
- Where page files must be touched, keep changes to:
  - command adapter registration
  - small state exposure methods
  - minimal focus hooks
- Avoid baking keyboard-specific rendering assumptions across many message/chat widgets.

## Immediate Next Steps

- Introduce a true shortcut registry instead of growing ad hoc resolver branches.
- Use registry data for both runtime dispatch and future help popup.
- Integrate highlighted-message navigation with existing selection model.
- Add scroll-to-highlight behavior.
- Add settings shortcut through the registry.
