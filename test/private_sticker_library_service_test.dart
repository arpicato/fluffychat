import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

class _FakeRoom extends Fake implements Room {}

class _FakeEvent extends Fake implements Event {
  _FakeEvent({
    required this.type,
    required this.messageType,
    required this.hasAttachment,
    this.body = '',
    this.content = const {},
  });

  @override
  final String type;

  @override
  final String messageType;

  @override
  final bool hasAttachment;

  @override
  final String body;

  @override
  final Map<String, Object?> content;

  @override
  Room get room => _FakeRoom();
}

void main() {
  test('sticker library accepts image messages', () {
    expect(
      isStickerLibraryEligibleEvent(
        _FakeEvent(
          type: EventTypes.Message,
          messageType: MessageTypes.Image,
          hasAttachment: true,
        ),
      ),
      isTrue,
    );
  });

  test('sticker library accepts sticker events', () {
    expect(
      isStickerLibraryEligibleEvent(
        _FakeEvent(
          type: EventTypes.Sticker,
          messageType: MessageTypes.Sticker,
          hasAttachment: true,
        ),
      ),
      isTrue,
    );
  });

  test('sticker library rejects non-image attachments', () {
    expect(
      isStickerLibraryEligibleEvent(
        _FakeEvent(
          type: EventTypes.Message,
          messageType: MessageTypes.File,
          hasAttachment: true,
        ),
      ),
      isFalse,
    );
  });

  test('sticker library entry json roundtrip preserves encrypted metadata', () {
    final entry = PrivateStickerLibraryEntry(
      id: 'id',
      code: 'code',
      body: 'body',
      createdAt: 1,
      file: {
        'url': 'mxc://server/id',
        'iv': 'iv',
        'hashes': {'sha256': 'hash'},
        'key': {'k': 'key'},
      },
      info: {'mimetype': 'image/webp', 'w': 256, 'h': 256},
      thumbnailFile: {
        'url': 'mxc://server/thumb',
        'iv': 'iv2',
        'hashes': {'sha256': 'hash2'},
        'key': {'k': 'key2'},
      },
      thumbnailInfo: {'mimetype': 'image/webp', 'w': 128, 'h': 128},
      animated: true,
      sourceRoomId: '!room:server',
      sourceEventId: '4event',
      packId: 'pack-1',
    );

    final roundtrip = PrivateStickerLibraryEntry.fromJson(
      Map<String, Object?>.from(entry.toJson()),
    );

    expect(roundtrip.file['url'], 'mxc://server/id');
    expect(roundtrip.thumbnailFile?['url'], 'mxc://server/thumb');
    expect(roundtrip.animated, isTrue);
    expect(roundtrip.sourceRoomId, '!room:server');
    expect(roundtrip.packId, 'pack-1');
  });

  test('sticker library prefers content body over unknown sticker fallback body', () {
    final service = PrivateStickerLibraryService.instance;
    final event = _FakeEvent(
      type: EventTypes.Sticker,
      messageType: MessageTypes.Sticker,
      hasAttachment: true,
      body: 'Unknown message format of type "m.sticker"',
      content: const {'body': 'Funny sticker'},
    );

    expect(service.suggestedNameForEvent(event), 'Funny sticker');
  });
}
