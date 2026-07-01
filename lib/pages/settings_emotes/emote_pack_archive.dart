// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';

Map<ArchiveFile, String> buildEmoteImportMap(Archive archive) {
  return Map.fromEntries(
    archive.files
        .where((file) => file.isFile)
        .map((file) => MapEntry(file, file.name.emoteNameFromPath))
        .sorted((a, b) => a.value.compareTo(b.value)),
  );
}

Map<String, dynamic> normalizeEmoteImageInfo(Map<String, dynamic> info) {
  final normalized = <String, dynamic>{...info};
  if (normalized['w'] is int && normalized['h'] is int) {
    final ratio = normalized['w'] / normalized['h'];
    if (normalized['w'] > normalized['h']) {
      normalized['w'] = 256;
      normalized['h'] = (256.0 / ratio).round();
    } else {
      normalized['h'] = 256;
      normalized['w'] = (ratio * 256.0).round();
    }
  }
  return normalized;
}

Uint8List encodeEmotePackArchive(Map<String, List<int>> entries) {
  final archive = Archive();
  for (final entry in entries.entries) {
    archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

String emotePackArchiveFileName(String? displayName, String? fallbackLocalpart) {
  return '${displayName ?? fallbackLocalpart ?? 'emotes'}.zip';
}

extension EmoteNameFromPath on String {
  String get emoteNameFromPath {
    return split(RegExp(r'[/\\]')).last
        .split('.')
        .first
        .toLowerCase()
        .replaceAll(RegExp(r'[^-\w]'), '_');
  }
}
