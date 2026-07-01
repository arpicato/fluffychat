// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:fluffychat/utils/client_manager.dart';
import 'package:fluffychat/services/backend_session_service.dart';
import 'package:fluffychat/services/messie_error_service.dart';
import 'package:matrix/matrix.dart';
import 'package:messie_api/messie_api.dart' as api;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

const privateStickerLibraryStaticMaxBytes = 256 * 1024;
const privateStickerLibraryAnimatedMaxBytes = 512 * 1024;
const privateStickerLibraryMaxDimension = 256;
const privateStickerLibraryPreviewDimension = 128;
const privateStickerLibraryDefaultPackName = 'Saved stickers';
const privateStickerLibraryBulkUploadChunkSize = 50;
const privateStickerLibraryPrepareConcurrency = 4;

bool isStickerLibraryEligibleEvent(Event event) =>
    (event.type == EventTypes.Sticker || event.type == EventTypes.Message) &&
    const {MessageTypes.Image, MessageTypes.Sticker}.contains(event.messageType) &&
    event.hasAttachment;

Map<String, dynamic> _encryptedFileToJson(EncryptedFile encrypted, Uri mxc, String mimeType) => {
  'url': mxc.toString(),
  'mimetype': mimeType,
  'v': 'v2',
  'key': {
    'alg': 'A256CTR',
    'ext': true,
    'k': encrypted.k,
    'key_ops': ['encrypt', 'decrypt'],
    'kty': 'oct',
  },
  'iv': encrypted.iv,
  'hashes': {'sha256': encrypted.sha256},
};

class PrivateStickerLibraryEntry {
  PrivateStickerLibraryEntry({
    required this.id,
    required this.code,
    required this.body,
    required this.createdAt,
    required this.file,
    required this.info,
    this.contentHash = '',
    this.thumbnailFile,
    this.thumbnailInfo,
    this.animated = false,
    this.sourceRoomId,
    this.sourceEventId,
    this.packId = '',
  });

  final String id;
  final String code;
  final String body;
  final int createdAt;
  final Map<String, dynamic> file;
  final Map<String, dynamic> info;
  final Map<String, dynamic>? thumbnailFile;
  final Map<String, dynamic>? thumbnailInfo;
  final bool animated;
  final String? sourceRoomId;
  final String? sourceEventId;
  final String packId;
  final String contentHash;

  factory PrivateStickerLibraryEntry.fromJson(Map<String, Object?> json) =>
      PrivateStickerLibraryEntry(
        id: json['id'] as String,
        code: json['code'] as String,
        body: (json['body'] as String?) ?? (json['code'] as String),
        createdAt: (json['created_at'] as int?) ?? 0,
        file: Map<String, dynamic>.from(json['file'] as Map),
        info: Map<String, dynamic>.from((json['info'] as Map?) ?? const {}),
        thumbnailFile: json['thumbnail_file'] is Map
            ? Map<String, dynamic>.from(json['thumbnail_file'] as Map)
            : null,
        thumbnailInfo: json['thumbnail_info'] is Map
            ? Map<String, dynamic>.from(json['thumbnail_info'] as Map)
            : null,
        animated: json['animated'] == true,
        sourceRoomId: json['source_room_id'] as String?,
        sourceEventId: json['source_event_id'] as String?,
        packId: _packIdFromJson(json),
        contentHash: (json['content_hash'] as String?) ?? '',
      );

  static String _packIdFromJson(Map<String, Object?> json) {
    final packId = json['pack_id'] as String?;
    if (packId != null && packId.isNotEmpty) return packId;
    final packIds = (json['pack_ids'] as List?)?.whereType<String>().toList();
    if (packIds != null && packIds.isNotEmpty) return packIds.first;
    return '';
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'code': code,
    'body': body,
    'created_at': createdAt,
    'file': file,
    'info': info,
    if (thumbnailFile != null) 'thumbnail_file': thumbnailFile,
    if (thumbnailInfo != null) 'thumbnail_info': thumbnailInfo,
    if (animated) 'animated': true,
    if (sourceRoomId != null) 'source_room_id': sourceRoomId,
    if (sourceEventId != null) 'source_event_id': sourceEventId,
    if (packId.isNotEmpty) 'pack_id': packId,
    if (contentHash.isNotEmpty) 'content_hash': contentHash,
  };
}

class PrivateStickerPack {
  PrivateStickerPack({required this.id, required this.name});

  final String id;
  final String name;

  factory PrivateStickerPack.fromJson(Map<String, Object?> json) =>
      PrivateStickerPack(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  Map<String, Object?> toJson() => {'id': id, 'name': name};
}

class PrivateStickerLibraryLimits {
  PrivateStickerLibraryLimits({
    required this.maxStickers,
    required this.usedStickers,
    required this.maxStickerBytes,
    required this.usedStickerBytes,
    required this.maxPacks,
    required this.usedPacks,
  });

  final int maxStickers;
  final int usedStickers;
  final int maxStickerBytes;
  final int usedStickerBytes;
  final int maxPacks;
  final int usedPacks;

  int get remainingStickers => maxStickers - usedStickers;

  factory PrivateStickerLibraryLimits.fromJson(Map<String, Object?> json) =>
      PrivateStickerLibraryLimits(
        maxStickers: (json['max_stickers'] as num?)?.toInt() ?? 0,
        usedStickers: (json['used_stickers'] as num?)?.toInt() ?? 0,
        maxStickerBytes: (json['max_sticker_bytes'] as num?)?.toInt() ?? 0,
        usedStickerBytes: (json['used_sticker_bytes'] as num?)?.toInt() ?? 0,
        maxPacks: (json['max_packs'] as num?)?.toInt() ?? 0,
        usedPacks: (json['used_packs'] as num?)?.toInt() ?? 0,
      );
}

class _PreparedStickerMedia {
  _PreparedStickerMedia({
    required this.file,
    required this.previewFile,
    required this.animated,
  });

  final MatrixImageFile file;
  final MatrixImageFile? previewFile;
  final bool animated;
}

class PrivateStickerLibraryService {
  PrivateStickerLibraryService._();

  static final instance = PrivateStickerLibraryService._();

  static final Map<String, Uint8List> _previewCache = {};
  final Map<String, List<PrivateStickerPack>> _packCache = {};
  final Map<String, List<PrivateStickerLibraryEntry>> _entryCache = {};
  final BackendSessionService _sessionService = BackendSessionService();
  final MessieErrorService _errorService = const MessieErrorService();
  final Map<String, PrivateStickerLibraryLimits> _limitsCache = {};
  final Set<String> _activeImportPackIds = <String>{};

  String _clientCacheKey(Client client) => client.userID ?? '';

  Future<_StickerApiClient> _createApiClient(Client client) async {
    final store = await SharedPreferences.getInstance();
    final session = await _sessionService.ensureSession(client, store);
    final sdk = api.MessieApi(
      basePathOverride: BackendSessionService.defaultApiBaseUrl,
      dio: Dio(
      BaseOptions(
        baseUrl: BackendSessionService.defaultApiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
      ),
    );
    sdk.setBearerAuth('bearerAuth', session.token);
    return _StickerApiClient(sdk: sdk, defaultApi: sdk.getDefaultApi());
  }

  Map<String, dynamic> _jsonObjectMapToMap(BuiltMap<String, JsonObject?> input) =>
      Map<String, dynamic>.fromEntries(
        input.entries.map((entry) => MapEntry(entry.key, entry.value?.value)),
      );

  PrivateStickerPack _packFromApi(api.StickerPack pack) => PrivateStickerPack(
    id: pack.id,
    name: pack.name,
  );

  List<PrivateStickerLibraryEntry> _entriesFromApi(api.StickerEntryListResponse response) {
    return response.entries.expand((entry) {
      final packIds = entry.packIds.toList();
      final baseEntry = PrivateStickerLibraryEntry(
        id: entry.id,
        code: entry.code,
        body: entry.body,
        createdAt: entry.createdAt,
        file: _jsonObjectMapToMap(entry.file),
        info: _jsonObjectMapToMap(entry.info),
        thumbnailFile: entry.thumbnailFile == null
            ? null
            : _jsonObjectMapToMap(entry.thumbnailFile!),
        thumbnailInfo: entry.thumbnailInfo == null
            ? null
            : _jsonObjectMapToMap(entry.thumbnailInfo!),
        animated: entry.animated ?? false,
        packId: packIds.isEmpty ? '' : packIds.first,
        contentHash: entry.contentHash,
      );
      if (packIds.isEmpty) return [baseEntry];
      return packIds
          .map(
            (packId) => PrivateStickerLibraryEntry(
              id: baseEntry.id,
              code: baseEntry.code,
              body: baseEntry.body,
              createdAt: baseEntry.createdAt,
              file: baseEntry.file,
              info: baseEntry.info,
              contentHash: baseEntry.contentHash,
              thumbnailFile: baseEntry.thumbnailFile,
              thumbnailInfo: baseEntry.thumbnailInfo,
              animated: baseEntry.animated,
              sourceRoomId: baseEntry.sourceRoomId,
              sourceEventId: baseEntry.sourceEventId,
              packId: packId,
            ),
          )
          .toList();
    }).toList();
  }

  void _cacheLibrary(
    Client client, {
    required List<PrivateStickerPack> packs,
    required List<PrivateStickerLibraryEntry> entries,
  }) {
    final sortedEntries = [...entries]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final cacheKey = _clientCacheKey(client);
    _packCache[cacheKey] = [...packs];
    _entryCache[cacheKey] = sortedEntries;
  }

  Future<Dio> _createAuthedDio(Client client) async {
    final sessionStore = await SharedPreferences.getInstance();
    final session = await _sessionService.ensureSession(client, sessionStore);
    return Dio(
      BaseOptions(
        baseUrl: BackendSessionService.defaultApiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Authorization': 'Bearer ${session.token}'},
      ),
    );
  }

  String suggestedNameForEvent(Event event) {
    final body = event.content.tryGet<String>('body')?.trim();
    if (body != null && body.isNotEmpty) return body;
    final filename = event.content.tryGet<String>('filename')?.trim();
    if (filename != null && filename.isNotEmpty) return filename;
    final eventBody = event.body.trim();
    if (eventBody.isNotEmpty && !eventBody.startsWith('Unknown message format')) {
      return eventBody;
    }
    return 'sticker';
  }

  List<PrivateStickerPack> packs(Client client) {
    final cacheKey = _clientCacheKey(client);
    if (_packCache.containsKey(cacheKey)) {
      return _packCache[cacheKey]!;
    }
    return _packCache[cacheKey] = const [];
  }

  PrivateStickerLibraryLimits? cachedLimits(Client client) =>
      _limitsCache[_clientCacheKey(client)];

  bool isPackImporting(String packId) => _activeImportPackIds.contains(packId);

  List<PrivateStickerLibraryEntry> entries(Client client) {
    final cacheKey = _clientCacheKey(client);
    if (_entryCache.containsKey(cacheKey)) {
      return _entryCache[cacheKey]!;
    }
    return _entryCache[cacheKey] = const [];
  }

  void _upsertEntryInCache(Client client, PrivateStickerLibraryEntry entry) {
    final cacheKey = _clientCacheKey(client);
    final currentEntries = [...(_entryCache[cacheKey] ?? const <PrivateStickerLibraryEntry>[])];
    currentEntries.removeWhere(
      (candidate) => candidate.id == entry.id && candidate.packId == entry.packId,
    );
    currentEntries.add(entry);
    currentEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _entryCache[cacheKey] = currentEntries;
  }

  void _replacePack(Client client, PrivateStickerPack updatedPack) {
    final cacheKey = _clientCacheKey(client);
    final currentPacks = _packCache[cacheKey] ?? const <PrivateStickerPack>[];
    _packCache[cacheKey] = currentPacks
        .map((pack) => pack.id == updatedPack.id ? updatedPack : pack)
        .toList();
  }

  void _removePackFromCache(Client client, String packId) {
    final cacheKey = _clientCacheKey(client);
    final currentPacks = _packCache[cacheKey] ?? const <PrivateStickerPack>[];
    _packCache[cacheKey] = currentPacks.where((pack) => pack.id != packId).toList();
    _entryCache[cacheKey] = (_entryCache[cacheKey] ?? const <PrivateStickerLibraryEntry>[])
        .where((entry) => entry.packId != packId)
        .toList();
  }

  void _moveEntryInCache(Client client, PrivateStickerLibraryEntry entry, String packId) {
    final cacheKey = _clientCacheKey(client);
    final currentEntries = [...(_entryCache[cacheKey] ?? const <PrivateStickerLibraryEntry>[])];
    final index = currentEntries.indexWhere(
      (candidate) => candidate.id == entry.id && candidate.packId == entry.packId,
    );
    if (index == -1) return;
    final currentEntry = currentEntries[index];
    currentEntries[index] = PrivateStickerLibraryEntry(
      id: currentEntry.id,
      code: currentEntry.code,
      body: currentEntry.body,
      createdAt: currentEntry.createdAt,
      file: currentEntry.file,
      info: currentEntry.info,
      contentHash: currentEntry.contentHash,
      thumbnailFile: currentEntry.thumbnailFile,
      thumbnailInfo: currentEntry.thumbnailInfo,
      animated: currentEntry.animated,
      sourceRoomId: currentEntry.sourceRoomId,
      sourceEventId: currentEntry.sourceEventId,
      packId: packId,
    );
    _entryCache[cacheKey] = currentEntries;
  }

  void _removeEntryFromCache(Client client, String entryId) {
    final cacheKey = _clientCacheKey(client);
    final currentEntries = _entryCache[cacheKey] ?? const <PrivateStickerLibraryEntry>[];
    _entryCache[cacheKey] = currentEntries.where((entry) => entry.id != entryId).toList();
  }

  Future<void> refresh(Client client) async {
    final apiClient = await _createApiClient(client);
    try {
      final packResponse = await apiClient.defaultApi.listStickerPacks();
      final entryResponse = await apiClient.defaultApi.listStickerEntries();
      final parsedPacks = (packResponse.data?.packs.toList() ?? const []).map(_packFromApi).toList();
      if (parsedPacks.isEmpty) {
        final createdDefaultPack = await createPack(
          client: client,
          name: privateStickerLibraryDefaultPackName,
        );
        _cacheLibrary(client, packs: [createdDefaultPack], entries: const []);
        return;
      }
      final parsedEntries = entryResponse.data == null
          ? const <PrivateStickerLibraryEntry>[]
          : _entriesFromApi(entryResponse.data!);
      _cacheLibrary(client, packs: parsedPacks, entries: parsedEntries);
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Load sticker library',
        error,
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<PrivateStickerLibraryLimits> loadLimits(Client client) async {
    final dio = await _createAuthedDio(client);
    try {
      final response = await dio.get<Map<String, dynamic>>('/stickers/limits');
      final limits = PrivateStickerLibraryLimits.fromJson(response.data ?? const {});
      _limitsCache[_clientCacheKey(client)] = limits;
      return limits;
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Load sticker limits',
        error,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<void> saveEventAsSticker({
    required Client client,
    required Event event,
    required String name,
    required String packId,
  }) async {
    if (!isStickerLibraryEligibleEvent(event)) {
      throw UnsupportedError('Only image and sticker messages can be saved to the sticker library.');
    }
    final originalFile = await _loadBestAvailableSourceFile(event);
    await saveFileAsSticker(
      client: client,
      file: originalFile,
      name: name,
      packId: packId,
    );
  }

  Future<void> saveFileAsSticker({
    required Client client,
    required MatrixFile file,
    required String name,
    String? packId,
    void Function(int prepareMs, int uploadMs, int totalMs, int bytes)? onTiming,
  }) async {
    final resolvedPackId = await _resolvePackId(client, packId);
    final resultMap = await bulkUploadFilesAsStickers(
      client: client,
      packId: resolvedPackId,
      onTiming: (requestId, prepareMs, uploadMs, totalMs, bytes) {
        if (requestId != 'single') return;
        onTiming?.call(prepareMs, uploadMs, totalMs, bytes);
      },
      stickers: [
        (
          requestId: 'single',
          file: file,
          name: name,
        ),
      ],
    );
    final error = resultMap['single'];
    if (error != null && error.isNotEmpty) {
      throw MessieUserException(
        kind: MessieErrorKind.server,
        userMessage: error,
        operation: 'Save sticker to library',
      );
    }
  }

  Future<Map<String, String?>> bulkUploadFilesAsStickers({
    required Client client,
    required String packId,
    required List<({String requestId, MatrixFile file, String name})> stickers,
    void Function(int completed, int total)? onProgress,
    void Function(String requestId, int prepareMs, int uploadMs, int totalMs, int bytes)? onTiming,
  }) async {
    _activeImportPackIds.add(packId);
    final dio = await _createAuthedDio(client);
    Future<List<({
      String requestId,
      String name,
      _PreparedStickerMedia media,
      _LocallyEncryptedMedia encrypted,
      String fileName,
    })>> prepareChunk(List<({String requestId, MatrixFile file, String name})> chunk) async {
      final prepared = <({
        String requestId,
        String name,
        _PreparedStickerMedia media,
        _LocallyEncryptedMedia encrypted,
        String fileName,
      })>[];
      for (var start = 0; start < chunk.length; start += privateStickerLibraryPrepareConcurrency) {
        final prepBatch = chunk
            .skip(start)
            .take(privateStickerLibraryPrepareConcurrency)
            .toList();
        final preparedBatch = await Future.wait(
          prepBatch.map((sticker) async {
            final media = await _prepareMedia(
              client,
              sticker.file,
              includePreview: false,
            );
            final encrypted = await _encryptMediaLocally(media.file);
            return (
              requestId: sticker.requestId,
              name: sticker.name,
              media: media,
              encrypted: encrypted,
              fileName: sticker.file.name,
            );
          }),
        );
        prepared.addAll(preparedBatch);
      }
      return prepared;
    }
    try {
      final resultMap = <String, String?>{};
      var completed = 0;
      Future<List<({
        String requestId,
        String name,
        _PreparedStickerMedia media,
        _LocallyEncryptedMedia encrypted,
        String fileName,
      })>>? nextChunkFuture;
      for (var start = 0; start < stickers.length; start += privateStickerLibraryBulkUploadChunkSize) {
        final sourceChunk = stickers
            .skip(start)
            .take(privateStickerLibraryBulkUploadChunkSize)
            .toList();
        final chunkStarted = DateTime.now();
        final chunkFuture = nextChunkFuture ?? prepareChunk(sourceChunk);
        final nextStart = start + privateStickerLibraryBulkUploadChunkSize;
        if (nextStart < stickers.length) {
          nextChunkFuture = prepareChunk(
            stickers.skip(nextStart).take(privateStickerLibraryBulkUploadChunkSize).toList(),
          );
        } else {
          nextChunkFuture = null;
        }
        final chunk = await chunkFuture;
        final prepareMs = DateTime.now().difference(chunkStarted).inMilliseconds;
        final payload = {
          'entries': chunk.map((sticker) {
            final contentHash = sha256.convert(sticker.media.file.bytes).toString();
            return {
              'client_request_id': sticker.requestId,
              'pack_id': packId,
              'content_hash': contentHash,
              'body': sticker.name,
              'encrypted_file': sticker.encrypted.fileJson,
              'info': sticker.encrypted.info,
              'thumbnail_encrypted_file': null,
              'thumbnail_info': null,
              'animated': sticker.media.animated,
              'size_bytes': sticker.media.file.bytes.length,
              'upload_content_type': lookupMimeType(sticker.fileName) ?? 'application/octet-stream',
              'upload_file_name': sticker.fileName,
              'upload_field_name': 'upload_${sticker.requestId}',
            };
          }).toList(),
        };
        final formData = FormData.fromMap({
          'payload': MultipartFile.fromString(jsonEncode(payload), filename: 'payload.json'),
          for (final sticker in chunk)
            'upload_${sticker.requestId}': MultipartFile.fromBytes(
              sticker.encrypted.encryptedBytes,
              filename: sticker.fileName,
              contentType: MediaType.parse(
                lookupMimeType(sticker.fileName) ?? 'application/octet-stream',
              ),
            ),
        });
        final uploadStarted = DateTime.now();
        final response = await dio.post<Map<String, dynamic>>(
          '/stickers/entries/bulk-upload',
          data: formData,
        );
        final uploadMs = DateTime.now().difference(uploadStarted).inMilliseconds;
        final results = (response.data?['results'] as List?) ?? const [];
        for (final raw in results.whereType<Map>()) {
          final result = Map<String, dynamic>.from(raw);
          final requestId = result['client_request_id'] as String?;
          if (requestId == null) continue;
          final success = result['success'] == true;
          if (success) {
            final entryJson = Map<String, Object?>.from(result['entry'] as Map);
            _upsertEntryInCache(client, PrivateStickerLibraryEntry.fromJson(entryJson));
            resultMap[requestId] = null;
          } else {
            resultMap[requestId] = result['message'] as String? ?? 'Import failed';
          }
          ({
            String requestId,
            String name,
            _PreparedStickerMedia media,
            _LocallyEncryptedMedia encrypted,
            String fileName,
          })? chunkEntry;
          for (final sticker in chunk) {
            if (sticker.requestId == requestId) {
              chunkEntry = sticker;
              break;
            }
          }
          if (chunkEntry != null) {
            onTiming?.call(
              requestId,
              prepareMs,
              uploadMs,
              prepareMs + uploadMs,
              chunkEntry.media.file.bytes.length,
            );
          }
        }
        completed += chunk.length;
        onProgress?.call(completed, stickers.length);
      }
      final limits = cachedLimits(client);
      if (limits != null) {
        _limitsCache[_clientCacheKey(client)] = PrivateStickerLibraryLimits(
          maxStickers: limits.maxStickers,
          usedStickers: limits.usedStickers + resultMap.values.where((e) => e == null).length,
          maxStickerBytes: limits.maxStickerBytes,
          usedStickerBytes: limits.usedStickerBytes,
          maxPacks: limits.maxPacks,
          usedPacks: limits.usedPacks,
        );
      }
      return resultMap;
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Bulk upload stickers',
        error,
      );
    } finally {
      _activeImportPackIds.remove(packId);
      dio.close(force: true);
    }
  }

  Future<String> _resolvePackId(Client client, String? packId) async {
    if (packId != null && packId.isNotEmpty) return packId;
    var availablePacks = packs(client);
    if (availablePacks.isEmpty) {
      await refresh(client);
      availablePacks = packs(client);
    }
    if (availablePacks.isEmpty) {
      throw Exception('No sticker pack is available.');
    }
    final preferred = availablePacks.firstWhere(
      (pack) => pack.name == privateStickerLibraryDefaultPackName,
      orElse: () => availablePacks.first,
    );
    return preferred.id;
  }

  Future<MatrixFile> _loadBestAvailableSourceFile(Event event) async {
    try {
      return await event.downloadAndDecryptAttachment();
    } catch (_) {
      try {
        return await event.downloadAndDecryptAttachment(getThumbnail: true);
      } catch (_) {
        throw Exception('Original sticker media is no longer available.');
      }
    }
  }

  Future<PrivateStickerPack> createPack({
    required Client client,
    required String name,
  }) async {
    final apiClient = await _createApiClient(client);
    try {
      final response = await apiClient.defaultApi.createStickerPack(
        createStickerPackRequest: api.CreateStickerPackRequest(
          (builder) => builder..name = name,
        ),
      );
      final newPack = _packFromApi(response.data!);
      final cacheKey = _clientCacheKey(client);
      final currentPacks = _packCache[cacheKey] ?? const <PrivateStickerPack>[];
      _packCache[cacheKey] = [...currentPacks, newPack];
      return newPack;
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Create sticker pack',
        error,
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<void> renamePack({
    required Client client,
    required String packId,
    required String name,
  }) async {
    final apiClient = await _createApiClient(client);
    try {
      final response = await apiClient.defaultApi.renameStickerPack(
        packId: packId,
        createStickerPackRequest: api.CreateStickerPackRequest(
          (builder) => builder..name = name,
        ),
      );
      _replacePack(client, _packFromApi(response.data!));
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Rename sticker pack',
        error,
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<void> deletePack({
    required Client client,
    required String packId,
    bool moveEntriesToDefault = true,
  }) async {
    final apiClient = await _createApiClient(client);
    try {
      await apiClient.defaultApi.deleteStickerPack(
        packId: packId,
        deleteStickerPackRequest: api.DeleteStickerPackRequest(
          (builder) => builder.mode = moveEntriesToDefault
              ? api.DeleteStickerPackRequestModeEnum.moveToSaved
              : api.DeleteStickerPackRequestModeEnum.deleteStickers,
        ),
      );
      if (moveEntriesToDefault) {
        await refresh(client);
      } else {
        _removePackFromCache(client, packId);
      }
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Delete sticker pack',
        error,
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<void> moveEntryToPack({
    required Client client,
    required PrivateStickerLibraryEntry entry,
    required String packId,
  }) async {
    final apiClient = await _createApiClient(client);
    try {
      await apiClient.defaultApi.moveStickerEntryToPack(
        entryId: entry.id,
        moveStickerEntryRequest: api.MoveStickerEntryRequest(
          (builder) => builder..packId = packId,
        ),
      );
      _moveEntryInCache(client, entry, packId);
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Move sticker to pack',
        error,
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<void> deleteEntry({
    required Client client,
    required PrivateStickerLibraryEntry entry,
  }) async {
    final sessionStore = await SharedPreferences.getInstance();
    final session = await _sessionService.ensureSession(client, sessionStore);
    final dio = Dio(
      BaseOptions(
        baseUrl: BackendSessionService.defaultApiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Authorization': 'Bearer ${session.token}'},
      ),
    );
    try {
      await dio.delete<void>(
        '/stickers/entries/${entry.id}',
        data: {'pack_id': entry.packId},
      );
      _removeEntryFromCache(client, entry.id);
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Delete saved sticker',
        error,
      );
    } finally {
      dio.close(force: true);
    }
    _previewCache.remove(entry.id);
  }

  Future<void> deleteEntries({
    required Client client,
    required String packId,
    required List<String> entryIds,
  }) async {
    if (entryIds.isEmpty) return;
    final apiClient = await _createApiClient(client);
    try {
      await apiClient.defaultApi.deleteStickerEntries(
        deleteStickerEntriesRequest: api.DeleteStickerEntriesRequest(
          (builder) => builder
            ..packId = packId
            ..entryIds.addAll(entryIds),
        ),
      );
      for (final entryId in entryIds) {
        _removeEntryFromCache(client, entryId);
      }
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Delete saved stickers',
        error,
      );
    } finally {
      apiClient.dispose();
    }
    for (final entryId in entryIds) {
      _previewCache.remove(entryId);
    }
  }

  Future<void> sendSticker({
    required Room room,
    required PrivateStickerLibraryEntry entry,
    String? threadRootEventId,
    String? threadLastEventId,
  }) async {
    if (room.encrypted && room.client.fileEncryptionEnabled) {
      await room.sendEvent(
        {
          'body': entry.body,
          'file': entry.file,
          'info': {
            ...entry.info,
            if (entry.thumbnailFile != null) 'thumbnail_file': entry.thumbnailFile,
            if (entry.thumbnailInfo != null) 'thumbnail_info': entry.thumbnailInfo,
          },
        },
        type: EventTypes.Sticker,
        threadRootEventId: threadRootEventId,
        threadLastEventId: threadLastEventId,
      );
      return;
    }

    final file = await downloadStickerFile(room.client, entry);
    final uploadResp = await room.client.uploadContent(
      file.bytes,
      filename: file.name,
      contentType: file.mimeType,
    );
    final thumbnail = await loadPreviewBytes(room.client, entry);
    await room.sendEvent(
      {
        'body': entry.body,
        'url': uploadResp.toString(),
        'info': {
          ...file.info,
          if (thumbnail != null) 'thumbnail_info': {
            'mimetype': file.mimeType,
            'size': thumbnail.length,
          },
        },
      },
      type: EventTypes.Sticker,
      threadRootEventId: threadRootEventId,
      threadLastEventId: threadLastEventId,
    );
  }

  Future<MatrixFile> downloadStickerFile(Client client, PrivateStickerLibraryEntry entry) async {
    final data = await _downloadEncryptedFileMap(client, entry.file);
    final mimeType = (entry.info['mimetype'] as String?) ?? 'image/png';
    final extension = extensionFromMime(mimeType) ?? 'bin';
    return MatrixFile.fromMimeType(
      bytes: data,
      name: '${entry.code}.$extension',
      mimeType: mimeType,
    );
  }

  Future<Uint8List?> loadPreviewBytes(Client client, PrivateStickerLibraryEntry entry) async {
    final cached = _previewCache[entry.id];
    if (cached != null) return cached;
    final previewFile = entry.thumbnailFile ?? entry.file;
    final data = await _downloadEncryptedFileMap(client, previewFile);
    _previewCache[entry.id] = data;
    return data;
  }

  Future<_PreparedStickerMedia> _prepareMedia(
    Client client,
    MatrixFile originalFile, {
    bool includePreview = true,
  }) async {
    if (!originalFile.mimeType.toLowerCase().startsWith('image/')) {
      throw UnsupportedError('Only image stickers are supported.');
    }

    final fastPath = _tryFastPathStaticSticker(originalFile);
    if (fastPath != null) {
      return _PreparedStickerMedia(
        file: fastPath,
        previewFile: null,
        animated: false,
      );
    }

    final animated = await _isAnimatedImage(originalFile.bytes);
    if (animated) {
      final imageFile = await MatrixImageFile.create(
        bytes: originalFile.bytes,
        name: originalFile.name,
        mimeType: originalFile.mimeType,
        nativeImplementations: client.nativeImplementations,
      );
      final width = imageFile.width ?? privateStickerLibraryMaxDimension + 1;
      final height = imageFile.height ?? privateStickerLibraryMaxDimension + 1;
      if (width > privateStickerLibraryMaxDimension ||
          height > privateStickerLibraryMaxDimension ||
          imageFile.bytes.length > privateStickerLibraryAnimatedMaxBytes) {
        throw UnsupportedError(
          'Animated stickers must already be at most 256x256 and 512 KB.',
        );
      }
      final previewFile = includePreview
          ? await imageFile.generateThumbnail(
              dimension: privateStickerLibraryPreviewDimension,
              customImageResizer: client.customImageResizer,
              nativeImplementations: client.nativeImplementations,
            )
          : null;
      return _PreparedStickerMedia(
        file: imageFile,
        previewFile: previewFile,
        animated: true,
      );
    }

    var imageFile = await MatrixImageFile.create(
      bytes: originalFile.bytes,
      name: originalFile.name,
      mimeType: originalFile.mimeType,
      nativeImplementations: client.nativeImplementations,
    );
    final width = imageFile.width;
    final height = imageFile.height;
    if ((width != null && width > privateStickerLibraryMaxDimension) ||
        (height != null && height > privateStickerLibraryMaxDimension)) {
      imageFile = await MatrixImageFile.shrink(
        bytes: imageFile.bytes,
        name: imageFile.name,
        mimeType: imageFile.mimeType,
        maxDimension: privateStickerLibraryMaxDimension,
        customImageResizer: client.customImageResizer,
        nativeImplementations: client.nativeImplementations,
      );
    }
    if (imageFile.bytes.length > privateStickerLibraryStaticMaxBytes) {
      throw UnsupportedError('Saved stickers must be at most 256 KB after resize.');
    }
    final previewFile = includePreview
        ? await imageFile.generateThumbnail(
            dimension: privateStickerLibraryPreviewDimension,
            customImageResizer: client.customImageResizer,
            nativeImplementations: client.nativeImplementations,
          )
        : null;
    return _PreparedStickerMedia(
      file: imageFile,
      previewFile: previewFile,
      animated: false,
    );
  }

  Future<bool> _isAnimatedImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      return codec.frameCount > 1;
    } catch (_) {
      return false;
    }
  }

  MatrixImageFile? _tryFastPathStaticSticker(MatrixFile originalFile) {
    final mimeType = originalFile.mimeType.toLowerCase();
    if (originalFile.bytes.length > privateStickerLibraryStaticMaxBytes) return null;
    final bytes = originalFile.bytes;
    if (mimeType == 'image/png') {
      if (bytes.length < 24) return null;
      const pngSignature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
      for (var i = 0; i < pngSignature.length; i++) {
        if (bytes[i] != pngSignature[i]) return null;
      }
      if (_containsAscii(bytes, 'acTL')) return null;
      final width = _readUint32BigEndian(bytes, 16);
      final height = _readUint32BigEndian(bytes, 20);
      if (width == null || height == null) return null;
      if (width > privateStickerLibraryMaxDimension ||
          height > privateStickerLibraryMaxDimension) {
        return null;
      }
      return MatrixImageFile(
        bytes: bytes,
        name: originalFile.name,
        mimeType: originalFile.mimeType,
        width: width,
        height: height,
      );
    }
    if (mimeType == 'image/webp') {
      final dimensions = _readWebpDimensions(bytes);
      if (dimensions == null) return null;
      if (dimensions.$1 > privateStickerLibraryMaxDimension ||
          dimensions.$2 > privateStickerLibraryMaxDimension) {
        return null;
      }
      return MatrixImageFile(
        bytes: bytes,
        name: originalFile.name,
        mimeType: originalFile.mimeType,
        width: dimensions.$1,
        height: dimensions.$2,
      );
    }
    return null;
  }

  bool _containsAscii(Uint8List bytes, String needle) {
    final needleCodes = needle.codeUnits;
    for (var start = 0; start <= bytes.length - needleCodes.length; start++) {
      var matched = true;
      for (var i = 0; i < needleCodes.length; i++) {
        if (bytes[start + i] != needleCodes[i]) {
          matched = false;
          break;
        }
      }
      if (matched) return true;
    }
    return false;
  }

  int? _readUint32BigEndian(Uint8List bytes, int offset) {
    if (offset + 4 > bytes.length) return null;
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  (int, int)? _readWebpDimensions(Uint8List bytes) {
    if (bytes.length < 30) return null;
    if (!_matchesAscii(bytes, 0, 'RIFF') || !_matchesAscii(bytes, 8, 'WEBP')) {
      return null;
    }
    final chunkType = String.fromCharCodes(bytes.sublist(12, 16));
    if (chunkType == 'VP8X') {
      if (bytes.length < 30) return null;
      final flags = bytes[20];
      if ((flags & 0x02) != 0) return null;
      final width = 1 + bytes[24] + (bytes[25] << 8) + (bytes[26] << 16);
      final height = 1 + bytes[27] + (bytes[28] << 8) + (bytes[29] << 16);
      return (width, height);
    }
    if (chunkType == 'VP8 ') {
      if (bytes.length < 30) return null;
      if (bytes[23] != 0x9d || bytes[24] != 0x01 || bytes[25] != 0x2a) {
        return null;
      }
      final width = (bytes[26] | (bytes[27] << 8)) & 0x3fff;
      final height = (bytes[28] | (bytes[29] << 8)) & 0x3fff;
      return (width, height);
    }
    if (chunkType == 'VP8L') {
      if (bytes.length < 25 || bytes[20] != 0x2f) return null;
      final b1 = bytes[21];
      final b2 = bytes[22];
      final b3 = bytes[23];
      final b4 = bytes[24];
      final width = 1 + (((b2 & 0x3F) << 8) | b1);
      final height = 1 + (((b4 & 0x0F) << 10) | (b3 << 2) | ((b2 & 0xC0) >> 6));
      return (width, height);
    }
    return null;
  }

  bool _matchesAscii(Uint8List bytes, int offset, String needle) {
    if (offset + needle.length > bytes.length) return false;
    final codes = needle.codeUnits;
    for (var i = 0; i < codes.length; i++) {
      if (bytes[offset + i] != codes[i]) return false;
    }
    return true;
  }

  Future<_LocallyEncryptedMedia> _encryptMediaLocally(MatrixFile file) async {
    final encrypted = await file.encrypt();
    return _LocallyEncryptedMedia(
      encryptedBytes: encrypted.data,
      fileJson: _encryptedFileToJson(encrypted, Uri.parse('mxc://placeholder/upload'), file.mimeType),
      info: file.info,
    );
  }

  Future<Uint8List> _downloadEncryptedFileMap(
    Client client,
    Map<String, dynamic> fileMap,
  ) async {
    final mxc = Uri.parse(fileMap['url'] as String);
    final httpUri = await mxc.getDownloadUri(client);
    final response = await client.httpClient.get(
      httpUri,
      headers: client.accessToken == null
          ? null
          : {'authorization': 'Bearer ${client.accessToken}'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to download sticker media.');
    }
    final encryptedFile = EncryptedFile(
      data: response.bodyBytes,
      iv: fileMap['iv'] as String,
      k: (fileMap['key'] as Map)['k'] as String,
      sha256: (fileMap['hashes'] as Map)['sha256'] as String,
    );
    final decrypted = await client.nativeImplementations.decryptFile(encryptedFile);
    if (decrypted == null) {
      throw Exception('Unable to decrypt saved sticker media.');
    }
    return decrypted;
  }
}

class _LocallyEncryptedMedia {
  _LocallyEncryptedMedia({required this.encryptedBytes, required this.fileJson, required this.info});

  final Uint8List encryptedBytes;
  final Map<String, dynamic> fileJson;
  final Map<String, dynamic> info;
}

class _StickerApiClient {
  _StickerApiClient({required this.sdk, required this.defaultApi});

  final api.MessieApi sdk;
  final api.DefaultApi defaultApi;

  void dispose() => sdk.dio.close(force: true);
}
