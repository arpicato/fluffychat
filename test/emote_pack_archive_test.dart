import 'package:archive/archive.dart';
import 'package:fluffychat/pages/settings_emotes/emote_pack_archive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildEmoteImportMap keeps files only and sorts by shortcode', () {
    final archive = Archive()
      ..addFile(ArchiveFile('zebra one.png', 3, [1, 2, 3]))
      ..addFile(ArchiveFile.directory('nested'))
      ..addFile(ArchiveFile('alpha/two words.webp', 2, [4, 5]));

    final importMap = buildEmoteImportMap(archive);

    expect(importMap.length, 2);
    expect(importMap.values.toList(), ['two_words', 'zebra_one']);
  });

  test('normalizeEmoteImageInfo constrains larger side to 256', () {
    expect(
      normalizeEmoteImageInfo({'w': 512, 'h': 256}),
      {'w': 256, 'h': 128},
    );
    expect(
      normalizeEmoteImageInfo({'w': 128, 'h': 512}),
      {'w': 64, 'h': 256},
    );
  });

  test('encodeEmotePackArchive writes named zip entries', () {
    final bytes = encodeEmotePackArchive({
      'one': [1, 2, 3],
      'two.webp': [4, 5],
    });
    final decoded = ZipDecoder().decodeBytes(bytes);

    expect(decoded.files.map((file) => file.name).toList(), ['one', 'two.webp']);
    expect(decoded.files.first.content, [1, 2, 3]);
    expect(decoded.files.last.content, [4, 5]);
  });

  test('emotePackArchiveFileName prefers display name then localpart', () {
    expect(emotePackArchiveFileName('My Pack', 'user'), 'My Pack.zip');
    expect(emotePackArchiveFileName(null, 'user'), 'user.zip');
    expect(emotePackArchiveFileName(null, null), 'emotes.zip');
  });
}
