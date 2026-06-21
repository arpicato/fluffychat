import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/chat/input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRoom extends Fake implements Room {}

class _FakeClient extends Fake implements Client {
  @override
  final Map<String, BasicEvent> accountData = {};

  @override
  List<Room> get rooms => const [];

  @override
  Map<String, CommandExecutionCallback> get commands => {
    'html': (_, _) async => null,
    'hug': (_, _) async => null,
  };
}

class _RoomForSuggestions extends Fake implements Room {
  @override
  final Map<String, Map<String, StrippedStateEvent>> states = {};

  @override
  Client get client => _FakeClient();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.init(loadWebConfigFile: false);
  });

  testWidgets('isCaretOnTopVisualLine detects first visual line', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'short');
    final focusNode = FocusNode();
    final editableKey = GlobalKey<EditableTextState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: EditableText(
              key: editableKey,
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              cursorColor: Colors.blue,
              backgroundCursorColor: Colors.grey,
              maxLines: 8,
            ),
          ),
        ),
      ),
    );

    controller.selection = const TextSelection.collapsed(offset: 0);
    await tester.pump();

    expect(
      isCaretOnTopVisualLine(
        editableTextState: editableKey.currentState!,
        selection: controller.selection,
      ),
      isTrue,
    );
  });

  testWidgets('isCaretOnTopVisualLine detects wrapped lower visual line', (
    tester,
  ) async {
    final controller = TextEditingController(
      text: 'This is a very long line that should soft wrap in a narrow field.',
    );
    final focusNode = FocusNode();
    final editableKey = GlobalKey<EditableTextState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: EditableText(
              key: editableKey,
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              cursorColor: Colors.blue,
              backgroundCursorColor: Colors.grey,
              maxLines: 8,
            ),
          ),
        ),
      ),
    );

    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    await tester.pump();

    expect(
      isCaretOnTopVisualLine(
        editableTextState: editableKey.currentState!,
        selection: controller.selection,
      ),
      isFalse,
    );
  });

  testWidgets('InputBar reports false when caret is on wrapped lower visual line', (
    tester,
  ) async {
    final controller = TextEditingController(
      text: 'This is a very long line that should soft wrap in a narrow field.',
    );
    final focusNode = FocusNode();
    bool? reportedTopVisualLine;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: InputBar(
              room: _FakeRoom(),
              minLines: 1,
              maxLines: 8,
              autofocus: false,
              keyboardType: TextInputType.multiline,
              focusNode: focusNode,
              controller: controller,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (_) {},
              onCaretTopVisualLineChanged: (value) {
                reportedTopVisualLine = value;
              },
              suggestionEmojis: const [],
            ),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    await tester.pump();
    await tester.pump();

    expect(reportedTopVisualLine, isFalse);
  });

  testWidgets('InputBar getSuggestions returns matching commands', (tester) async {
    final inputBar = InputBar(
      room: _RoomForSuggestions(),
      minLines: 1,
      maxLines: 8,
      autofocus: false,
      keyboardType: TextInputType.multiline,
      focusNode: FocusNode(),
      controller: TextEditingController(),
      decoration: const InputDecoration(border: InputBorder.none),
      onChanged: (_) {},
      suggestionEmojis: const [Emoji('😀', 'grinning face')],
    );
    expect(
      inputBar.getSuggestions(
        const TextEditingValue(
          text: '/h',
          selection: TextSelection.collapsed(offset: 2),
        ),
      ).map((s) => s['name']).toList(),
      ['html', 'hug'],
    );
  });

  testWidgets('RawAutocomplete opens with external controller and focus node', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var sawOptions = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: widgets.RawAutocomplete<String>(
            focusNode: focusNode,
            textEditingController: controller,
            optionsBuilder: (text) {
              final options = text.text == '/h' ? ['html', 'hug'] : const <String>[];
              if (options.isNotEmpty) {
                sawOptions = true;
              }
              return options;
            },
            fieldViewBuilder: (context, controller, focusNode, _) => TextField(
              controller: controller,
              focusNode: focusNode,
            ),
            optionsViewBuilder: (context, onSelected, options) => Material(
              child: ListView(
                shrinkWrap: true,
                children: options
                    .map((option) => ListTile(title: Text(option)))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    controller.value = const TextEditingValue(
      text: '/h',
      selection: TextSelection.collapsed(offset: 2),
    );
    await tester.pump();
    await tester.pump();

    expect(sawOptions, isTrue);
    expect(find.text('html'), findsOneWidget);
  });

  testWidgets('Autocomplete with InputBar-style map options opens', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var sawOptions = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Autocomplete<Map<String, String?>>( 
            focusNode: focusNode,
            textEditingController: controller,
            optionsBuilder: (text) {
              final options = text.text == '/h'
                  ? [
                      {'type': 'command', 'name': 'html'},
                      {'type': 'command', 'name': 'hug'},
                    ]
                  : const <Map<String, String?>>[];
              if (options.isNotEmpty) {
                sawOptions = true;
              }
              return options;
            },
            displayStringForOption: (option) => option['name']!,
            fieldViewBuilder: (context, controller, focusNode, _) => TextField(
              controller: controller,
              focusNode: focusNode,
            ),
            optionsViewBuilder: (context, onSelected, options) => Material(
              child: ListView(
                shrinkWrap: true,
                children: options
                    .map((option) => ListTile(title: Text(option['name']!)))
                    .toList(),
              ),
            ),
            optionsViewOpenDirection: OptionsViewOpenDirection.up,
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    controller.value = const TextEditingValue(
      text: '/h',
      selection: TextSelection.collapsed(offset: 2),
    );
    await tester.pump();
    await tester.pump();

    expect(sawOptions, isTrue);
    expect(find.text('html'), findsOneWidget);
  });

  testWidgets('Autocomplete map options react with keyed widget and callback side effect', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    List<Map<String, String?>>? computed;
    bool? open;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: Autocomplete<Map<String, String?>>(
              key: const Key('chat_input_field'),
              focusNode: focusNode,
              textEditingController: controller,
              optionsBuilder: (text) {
                final suggestions = text.text == '/h'
                    ? [
                        {'type': 'command', 'name': 'html'},
                        {'type': 'command', 'name': 'hug'},
                      ]
                    : const <Map<String, String?>>[];
                computed = suggestions;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  open = suggestions.isNotEmpty;
                });
                return suggestions;
              },
              displayStringForOption: (option) => option['name']!,
              fieldViewBuilder: (context, controller, focusNode, _) => TextField(
                controller: controller,
                focusNode: focusNode,
              ),
              optionsViewBuilder: (context, onSelected, options) => Material(
                child: ListView(
                  shrinkWrap: true,
                  children: options
                      .map((option) => ListTile(title: Text(option['name']!)))
                      .toList(),
                ),
              ),
              optionsViewOpenDirection: OptionsViewOpenDirection.up,
            ),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    controller.value = const TextEditingValue(
      text: '/h',
      selection: TextSelection.collapsed(offset: 2),
    );
    await tester.pump();
    await tester.pump();

    expect(computed?.map((s) => s['name']).toList(), ['html', 'hug']);
    expect(open, isTrue);
  });

  testWidgets('Autocomplete with InputBar text field shape still computes options', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    List<Map<String, String?>>? computed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: Autocomplete<Map<String, String?>>(
              focusNode: focusNode,
              textEditingController: controller,
              optionsBuilder: (text) {
                final suggestions = text.text == '/h'
                    ? [
                        {'type': 'command', 'name': 'html'},
                        {'type': 'command', 'name': 'hug'},
                      ]
                    : const <Map<String, String?>>[];
                computed = suggestions;
                return suggestions;
              },
              displayStringForOption: (option) => option['name']!,
              fieldViewBuilder: (context, controller, focusNode, _) => TextField(
                controller: controller,
                focusNode: focusNode,
                onEditingComplete: () {},
                contextMenuBuilder: (c, e) => const SizedBox.shrink(),
                contentInsertionConfiguration: ContentInsertionConfiguration(
                  onContentInserted: (_) {},
                ),
                minLines: 1,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                autofocus: false,
                inputFormatters: [
                  LengthLimitingTextInputFormatter((maxPDUSize / 3).floor()),
                ],
                maxLength: 1000,
                decoration: const InputDecoration(border: InputBorder.none),
                textCapitalization: TextCapitalization.sentences,
              ),
              optionsViewBuilder: (context, onSelected, options) => Material(
                child: ListView(
                  shrinkWrap: true,
                  children: options
                      .map((option) => ListTile(title: Text(option['name']!)))
                      .toList(),
                ),
              ),
              optionsViewOpenDirection: OptionsViewOpenDirection.up,
            ),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    controller.value = const TextEditingValue(
      text: '/h',
      selection: TextSelection.collapsed(offset: 2),
    );
    await tester.pump();
    await tester.pump();

    expect(computed?.map((s) => s['name']).toList(), ['html', 'hug']);
  });

  testWidgets('InputBar submit accepts highlighted emoji suggestion before send', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    String? submitted;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: InputBar(
              room: _RoomForSuggestions(),
              minLines: 1,
              maxLines: 8,
              autofocus: false,
              keyboardType: TextInputType.multiline,
              focusNode: focusNode,
              controller: controller,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (_) {},
              onSubmitted: (value) => submitted = value,
              suggestionEmojis: const [Emoji('😀', 'grinning face')],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    focusNode.requestFocus();
    await tester.pump();

    await tester.enterText(find.byType(TextField), ':gri');
    controller.selection = const TextSelection.collapsed(offset: 4);
    await tester.pump();
    await tester.pump();

    expect(find.text('grinning face'), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(controller.text, '😀 ');
    expect(submitted, isNull);
  });

  testWidgets('InputBar closes suggestions after accepting emoji', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    bool? suggestionsOpen;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: InputBar(
              room: _RoomForSuggestions(),
              minLines: 1,
              maxLines: 8,
              autofocus: false,
              keyboardType: TextInputType.multiline,
              focusNode: focusNode,
              controller: controller,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (_) {},
              onSubmitted: (_) {},
              onSuggestionsOpenChanged: (value) => suggestionsOpen = value,
              suggestionEmojis: const [Emoji('😀', 'grinning face')],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    focusNode.requestFocus();
    await tester.pump();

    await tester.enterText(find.byType(TextField), ':gri');
    controller.selection = const TextSelection.collapsed(offset: 4);
    await tester.pump();
    await tester.pump();

    expect(suggestionsOpen, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(controller.text, '😀 ');
    expect(suggestionsOpen, isFalse);
  });

}
