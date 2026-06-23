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
import 'package:shared_preferences/shared_preferences.dart';

const privateStickerLibraryStaticMaxBytes = 256 * 1024;
const privateStickerLibraryAnimatedMaxBytes = 512 * 1024;
const privateStickerLibraryMaxDimension = 256;
const privateStickerLibraryPreviewDimension = 128;
const privateStickerLibraryDefaultPackName = 'Saved stickers';

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

  List<PrivateStickerLibraryEntry> entries(Client client) {
    final cacheKey = _clientCacheKey(client);
    if (_entryCache.containsKey(cacheKey)) {
      return _entryCache[cacheKey]!;
    }
    return _entryCache[cacheKey] = const [];
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
    final prepared = await _prepareMedia(client, originalFile);
    final uploadedFile = await _uploadEncryptedMedia(client, prepared.file);
    final uploadedPreview = prepared.previewFile == null
        ? null
        : await _uploadEncryptedMedia(client, prepared.previewFile!);

    final apiClient = await _createApiClient(client);
    try {
      final contentHash = sha256.convert(prepared.file.bytes).toString();
      final request = api.SaveStickerEntryRequest(
        (builder) => builder
          ..packId = packId
          ..contentHash = contentHash
          ..body = name
          ..encryptedFile.replace(
            Map<String, JsonObject?>.fromEntries(
              uploadedFile.fileJson.entries.map(
                (entry) => MapEntry(entry.key, JsonObject(entry.value)),
              ),
            ),
          )
          ..info.replace(
            Map<String, JsonObject?>.fromEntries(
              uploadedFile.info.entries.map(
                (entry) => MapEntry(entry.key, JsonObject(entry.value)),
              ),
            ),
          )
          ..thumbnailEncryptedFile = (uploadedPreview?.fileJson == null)
              ? null
              : MapBuilder<String, JsonObject?>(
                  Map<String, JsonObject?>.fromEntries(
                    uploadedPreview!.fileJson.entries.map(
                      (entry) => MapEntry(entry.key, JsonObject(entry.value)),
                    ),
                  ),
                )
          ..thumbnailInfo = (uploadedPreview?.info == null)
              ? null
              : MapBuilder<String, JsonObject?>(
                  Map<String, JsonObject?>.fromEntries(
                    uploadedPreview!.info.entries.map(
                      (entry) => MapEntry(entry.key, JsonObject(entry.value)),
                    ),
                  ),
                )
          ..animated = prepared.animated
          ..sizeBytes = prepared.file.bytes.length
          ..mxcUri = uploadedFile.fileJson['url'] as String
          ..mediaId = Uri.parse(uploadedFile.fileJson['url'] as String).pathSegments.last,
      );
      final response = await apiClient.defaultApi.saveStickerEntry(
        saveStickerEntryRequest: request,
      );
      final savedEntry = response.data == null
          ? throw Exception('Backend returned invalid sticker entry payload.')
          : _entriesFromApi(
              api.StickerEntryListResponse(
                (builder) => builder..entries.add(response.data!),
              ),
            ).first;
      await refresh(client);
      _previewCache.remove(savedEntry.id);
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/stickers',
        'Save sticker to library',
        error,
      );
    } finally {
      apiClient.dispose();
    }
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
      await refresh(client);
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
      await apiClient.defaultApi.renameStickerPack(
        packId: packId,
        createStickerPackRequest: api.CreateStickerPackRequest(
          (builder) => builder..name = name,
        ),
      );
      await refresh(client);
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
      await refresh(client);
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
      await refresh(client);
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
      await refresh(client);
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

  Future<_PreparedStickerMedia> _prepareMedia(Client client, MatrixFile originalFile) async {
    if (!originalFile.mimeType.toLowerCase().startsWith('image/')) {
      throw UnsupportedError('Only image stickers are supported.');
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
      final previewFile = await imageFile.generateThumbnail(
        dimension: privateStickerLibraryPreviewDimension,
        customImageResizer: client.customImageResizer,
        nativeImplementations: client.nativeImplementations,
      );
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
    final previewFile = await imageFile.generateThumbnail(
      dimension: privateStickerLibraryPreviewDimension,
      customImageResizer: client.customImageResizer,
      nativeImplementations: client.nativeImplementations,
    );
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

  Future<_UploadedEncryptedMedia> _uploadEncryptedMedia(Client client, MatrixFile file) async {
    final encrypted = await file.encrypt();
    final uploadResp = await client.uploadContent(
      encrypted.data,
      filename: file.name,
      contentType: file.mimeType,
    );
    return _UploadedEncryptedMedia(
      fileJson: _encryptedFileToJson(encrypted, uploadResp, file.mimeType),
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

class _UploadedEncryptedMedia {
  _UploadedEncryptedMedia({required this.fileJson, required this.info});

  final Map<String, dynamic> fileJson;
  final Map<String, dynamic> info;
}

class _StickerApiClient {
  _StickerApiClient({required this.sdk, required this.defaultApi});

  final api.MessieApi sdk;
  final api.DefaultApi defaultApi;

  void dispose() => sdk.dio.close(force: true);
}
