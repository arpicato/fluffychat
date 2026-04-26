import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:messie_api/messie_api.dart' as api;

String _normalizeMessieCalendarApiBaseUrl(String value) =>
    value.endsWith('/') ? value : '$value/';

String _normalizeMessieCalendarCategory(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty
      ? defaultMessieCalendarCategory
      : trimmed;
}

const defaultMessieCalendarCategory = 'My Calendars';

class MessieCalendarSource {
  MessieCalendarSource({
    required this.id,
    required this.userId,
    required this.kind,
    required this.displayName,
    required this.category,
    required this.importMode,
    required this.refreshState,
    this.sourceUrl,
    this.lastSyncedAt,
    this.lastRefreshAttemptAt,
    this.lastRefreshError,
    this.etag,
    this.lastModified,
    this.nextRefreshAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String kind;
  final String displayName;
  final String category;
  final String importMode;
  final String refreshState;
  final String? sourceUrl;
  final DateTime? lastSyncedAt;
  final DateTime? lastRefreshAttemptAt;
  final String? lastRefreshError;
  final String? etag;
  final DateTime? lastModified;
  final DateTime? nextRefreshAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MessieCalendarSource.fromApi(api.CalendarSource source) =>
      MessieCalendarSource(
        id: source.id,
        userId: source.userId,
        kind: source.kind,
        displayName: source.displayName?.trim() ?? '',
        category: source.category,
        importMode: source.importMode,
        refreshState: source.refreshState,
        sourceUrl: source.sourceUrl,
        lastSyncedAt: source.lastSyncedAt,
        lastRefreshAttemptAt: source.lastRefreshAttemptAt,
        lastRefreshError: source.lastRefreshError,
        etag: source.etag,
        lastModified: source.lastModified,
        nextRefreshAt: source.nextRefreshAt,
        createdAt: source.createdAt,
        updatedAt: source.updatedAt,
      );
}

class MessieCalendarEvent {
  MessieCalendarEvent({
    required this.id,
    required this.sourceId,
    required this.externalUid,
    required this.title,
    required this.description,
    required this.location,
    required this.startsAt,
    required this.endsAt,
    required this.allDay,
    required this.status,
    required this.timezone,
    required this.sourceDisplayName,
    this.recurrenceSummary,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String sourceId;
  final String externalUid;
  final String title;
  final String description;
  final String location;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool allDay;
  final String status;
  final String timezone;
  final String sourceDisplayName;
  final String? recurrenceSummary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isUpcoming => endsAt.isAfter(DateTime.now().toUtc());
  bool get isRecurring =>
      recurrenceSummary != null && recurrenceSummary!.isNotEmpty;

  factory MessieCalendarEvent.fromApi(api.CalendarEvent event) =>
      MessieCalendarEvent(
        id: event.id,
        sourceId: event.sourceId,
        externalUid: event.externalUid,
        title: event.title,
        description: event.description,
        location: event.location,
        startsAt: event.startsAt,
        endsAt: event.endsAt,
        allDay: event.allDay,
        status: event.status,
        timezone: event.timezone,
        sourceDisplayName: event.sourceDisplayName,
        recurrenceSummary: event.recurrenceSummary,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
      );
}

class MessieCalendarImportResult {
  MessieCalendarImportResult({
    required this.source,
    required this.importedEventCount,
  });

  final MessieCalendarSource source;
  final int importedEventCount;

  factory MessieCalendarImportResult.fromApi(
    api.CalendarImportResponse response,
  ) => MessieCalendarImportResult(
    source: MessieCalendarSource.fromApi(response.source_),
    importedEventCount: response.importedEventCount,
  );
}

abstract class MessieCalendarSdk {
  Future<api.CalendarImportResponse> importCalendarSource({
    required List<int> bytes,
    required String filename,
    String? category,
    String? displayName,
  });

  Future<List<api.CalendarSource>> getCalendarSources();

  Future<api.CalendarImportResponse> createLinkedCalendarSource({
    required String url,
    String? category,
    String? displayName,
  });

  Future<api.CalendarSource> getCalendarSourceById({required String sourceId});

  Future<api.CalendarSource> updateCalendarSource({
    required String sourceId,
    String? category,
    required String displayName,
  });

  Future<api.CalendarImportResponse> refreshCalendarSource({
    required String sourceId,
  });

  Future<void> deleteCalendarSource({required String sourceId});

  Future<List<api.CalendarEvent>> getCalendarEvents({
    DateTime? from,
    DateTime? to,
    String? sourceId,
    DateTime? cursor,
    String? direction,
    int? limit,
  });

  Future<api.CalendarEvent> getCalendarEventById({required String eventId});

  Future<List<api.CalendarEvent>> getUpcomingCalendarEvents({int? limit});
}

class GeneratedMessieCalendarSdk implements MessieCalendarSdk {
  GeneratedMessieCalendarSdk({required String apiBaseUrl, required String jwt})
    : _api = _createApi(apiBaseUrl: apiBaseUrl, jwt: jwt);

  final api.DefaultApi _api;

  static api.DefaultApi _createApi({
    required String apiBaseUrl,
    required String jwt,
  }) {
    final sdk = api.MessieApi(
      basePathOverride: _normalizeMessieCalendarApiBaseUrl(apiBaseUrl),
    );
    sdk.setBearerAuth('bearerAuth', jwt);
    return sdk.getDefaultApi();
  }

  @override
  Future<api.CalendarImportResponse> importCalendarSource({
    required List<int> bytes,
    required String filename,
    String? category,
    String? displayName,
  }) async {
    final response = await _api.importCalendarSource(
      file: MultipartFile.fromBytes(bytes, filename: filename),
      category: _normalizeMessieCalendarCategory(category),
      displayName: displayName,
    );
    return response.data!;
  }

  @override
  Future<List<api.CalendarSource>> getCalendarSources() async {
    final response = await _api.getCalendarSources();
    return response.data?.toList() ?? const [];
  }

  @override
  Future<api.CalendarImportResponse> createLinkedCalendarSource({
    required String url,
    String? category,
    String? displayName,
  }) async {
    final response = await _api.createLinkedCalendarSource(
      newCalendarLinkSource: api.NewCalendarLinkSource(
        (b) => b
          ..url = url
          ..category = _normalizeMessieCalendarCategory(category)
          ..displayName = displayName,
      ),
    );
    return response.data!;
  }

  @override
  Future<api.CalendarSource> getCalendarSourceById({
    required String sourceId,
  }) async {
    final response = await _api.getCalendarSourceById(sourceId: sourceId);
    return response.data!;
  }

  @override
  Future<api.CalendarSource> updateCalendarSource({
    required String sourceId,
    String? category,
    required String displayName,
  }) async {
    final response = await _api.updateCalendarSource(
      sourceId: sourceId,
      updateCalendarSource: api.UpdateCalendarSource(
        (b) => b
          ..category = _normalizeMessieCalendarCategory(category)
          ..displayName = displayName,
      ),
    );
    return response.data!;
  }

  @override
  Future<api.CalendarImportResponse> refreshCalendarSource({
    required String sourceId,
  }) async {
    final response = await _api.refreshCalendarSource(sourceId: sourceId);
    return response.data!;
  }

  @override
  Future<void> deleteCalendarSource({required String sourceId}) async {
    await _api.deleteCalendarSource(sourceId: sourceId);
  }

  @override
  Future<List<api.CalendarEvent>> getCalendarEvents({
    DateTime? from,
    DateTime? to,
    String? sourceId,
    DateTime? cursor,
    String? direction,
    int? limit,
  }) async {
    final response = await _api.getCalendarEvents(
      from: from,
      to: to,
      sourceId: sourceId,
      cursor: cursor,
      direction: direction,
      limit: limit,
    );
    return response.data?.toList() ?? const [];
  }

  @override
  Future<api.CalendarEvent> getCalendarEventById({
    required String eventId,
  }) async {
    final response = await _api.getCalendarEventById(eventId: eventId);
    return response.data!;
  }

  @override
  Future<List<api.CalendarEvent>> getUpcomingCalendarEvents({
    int? limit,
  }) async {
    final response = await _api.getUpcomingCalendarEvents(limit: limit);
    return response.data?.toList() ?? const [];
  }
}

typedef MessieCalendarSdkFactory =
    MessieCalendarSdk Function({
      required String apiBaseUrl,
      required String jwt,
    });

class MessieCalendarService {
  MessieCalendarService({MessieCalendarSdkFactory? sdkFactory})
    : _sdkFactory = sdkFactory ?? GeneratedMessieCalendarSdk.new;

  final MessieCalendarSdkFactory _sdkFactory;

  Object? _decodeErrorPayload(Object? data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Uint8List) {
      final text = utf8.decode(data, allowMalformed: true);
      return _decodeErrorPayload(text);
    }
    if (data is List<int>) {
      final text = utf8.decode(data, allowMalformed: true);
      return _decodeErrorPayload(text);
    }
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return jsonDecode(trimmed);
        } catch (_) {
          return trimmed;
        }
      }
      return trimmed;
    }
    return data;
  }

  String? _extractServerMessage(Object? data) {
    final decoded = _decodeErrorPayload(data);
    if (decoded is Map) {
      final message =
          decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          decoded['detail']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    if (decoded is String && decoded.isNotEmpty) return decoded;
    return null;
  }

  Exception _requestException(String message, DioException error) {
    final statusCode = error.response?.statusCode?.toString() ?? 'unknown';
    final serverMessage =
        _extractServerMessage(error.response?.data) ??
        _extractServerMessage(error.error);
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return Exception(serverMessage);
    }
    final data = error.response?.data ?? error.error;
    final body = data == null
        ? ''
        : data is String
        ? data
        : jsonEncode(_decodeErrorPayload(data));
    return Exception('$message ($statusCode): $body');
  }

  Exception _genericException(String message, Object error) {
    final serverMessage = _extractServerMessage(error);
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return Exception(serverMessage);
    }
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return Exception(text.substring('Exception: '.length));
    }
    return Exception('$message: $text');
  }

  Future<T> _wrapRequest<T>(
    String message,
    Future<T> Function(MessieCalendarSdk sdk) callback, {
    required String apiBaseUrl,
    required String jwt,
  }) async {
    final sdk = _sdkFactory(apiBaseUrl: apiBaseUrl, jwt: jwt);
    try {
      return await callback(sdk);
    } on DioException catch (error) {
      throw _requestException(message, error);
    } catch (error) {
      throw _genericException(message, error);
    }
  }

  Future<MessieCalendarImportResult> importCalendarSource({
    required String apiBaseUrl,
    required String jwt,
    required XFile file,
    String? category,
    String? displayName,
  }) async => _wrapRequest(
    'Failed to import calendar source',
    (sdk) async => MessieCalendarImportResult.fromApi(
      await sdk.importCalendarSource(
        bytes: await file.readAsBytes(),
        filename: file.name.isEmpty ? 'calendar.ics' : file.name,
        category: _normalizeMessieCalendarCategory(category),
        displayName: displayName,
      ),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<List<MessieCalendarSource>> getCalendarSources({
    required String apiBaseUrl,
    required String jwt,
  }) async => _wrapRequest(
    'Failed to load calendar sources',
    (sdk) async => (await sdk.getCalendarSources())
        .map(MessieCalendarSource.fromApi)
        .toList(),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieCalendarImportResult> createLinkedCalendarSource({
    required String apiBaseUrl,
    required String jwt,
    required String url,
    String? category,
    String? displayName,
  }) async => _wrapRequest(
    'Failed to add linked calendar source',
    (sdk) async => MessieCalendarImportResult.fromApi(
      await sdk.createLinkedCalendarSource(
        url: url,
        category: _normalizeMessieCalendarCategory(category),
        displayName: displayName,
      ),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieCalendarSource> getCalendarSourceById({
    required String apiBaseUrl,
    required String jwt,
    required String sourceId,
  }) async => _wrapRequest(
    'Failed to load calendar source',
    (sdk) async => MessieCalendarSource.fromApi(
      await sdk.getCalendarSourceById(sourceId: sourceId),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieCalendarSource> updateCalendarSource({
    required String apiBaseUrl,
    required String jwt,
    required String sourceId,
    String? category,
    required String displayName,
  }) async => _wrapRequest(
    'Failed to update calendar source',
    (sdk) async => MessieCalendarSource.fromApi(
      await sdk.updateCalendarSource(
        sourceId: sourceId,
        category: _normalizeMessieCalendarCategory(category),
        displayName: displayName,
      ),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieCalendarImportResult> refreshCalendarSource({
    required String apiBaseUrl,
    required String jwt,
    required String sourceId,
  }) async => _wrapRequest(
    'Failed to refresh calendar source',
    (sdk) async => MessieCalendarImportResult.fromApi(
      await sdk.refreshCalendarSource(sourceId: sourceId),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<void> deleteCalendarSource({
    required String apiBaseUrl,
    required String jwt,
    required String sourceId,
  }) async => _wrapRequest(
    'Failed to delete calendar source',
    (sdk) => sdk.deleteCalendarSource(sourceId: sourceId),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<List<MessieCalendarEvent>> getCalendarEvents({
    required String apiBaseUrl,
    required String jwt,
    DateTime? from,
    DateTime? to,
    String? sourceId,
    DateTime? cursor,
    String? direction,
    int? limit,
  }) async => _wrapRequest(
    'Failed to load calendar events',
    (sdk) async => (await sdk.getCalendarEvents(
      from: from?.toUtc(),
      to: to?.toUtc(),
      sourceId: sourceId,
      cursor: cursor?.toUtc(),
      direction: direction,
      limit: limit,
    )).map(MessieCalendarEvent.fromApi).toList(),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieCalendarEvent> getCalendarEventById({
    required String apiBaseUrl,
    required String jwt,
    required String eventId,
  }) async => _wrapRequest(
    'Failed to load calendar event',
    (sdk) async => MessieCalendarEvent.fromApi(
      await sdk.getCalendarEventById(eventId: eventId),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<List<MessieCalendarEvent>> getUpcomingCalendarEvents({
    required String apiBaseUrl,
    required String jwt,
    int? limit,
  }) async => _wrapRequest(
    'Failed to load upcoming calendar events',
    (sdk) async => (await sdk.getUpcomingCalendarEvents(
      limit: limit,
    )).map(MessieCalendarEvent.fromApi).toList(),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );
}
