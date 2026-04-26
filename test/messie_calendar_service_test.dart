import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messie_api/messie_api.dart' as api;

class RecordingMessieCalendarSdk implements MessieCalendarSdk {
  List<int>? importedBytes;
  String? importedFilename;
  String? importedCategory;
  String? importedDisplayName;
  bool deletedSource = false;
  String? linkedUrl;
  String? linkedCategory;
  String? linkedDisplayName;
  String? deletedSourceId;
  String? updatedSourceId;
  String? updatedCategory;
  String? updatedDisplayName;
  String? refreshedSourceId;
  String? requestedEventId;
  DateTime? requestedFrom;
  DateTime? requestedTo;
  String? requestedSourceId;
  int? requestedLimit;

  @override
  Future<api.CalendarImportResponse> importCalendarSource({
    required List<int> bytes,
    required String filename,
    String? category,
    String? displayName,
  }) async {
    importedBytes = bytes;
    importedFilename = filename;
    importedCategory = category;
    importedDisplayName = displayName;
    return api.CalendarImportResponse(
      (builder) => builder
        ..source_.id = 'source-1'
        ..source_.userId = 'user-1'
        ..source_.kind = 'ics_file'
        ..source_.displayName = displayName ?? 'Imported'
        ..source_.category = category
        ..source_.importMode = 'upload'
        ..source_.refreshState = 'imported'
        ..importedEventCount = 2,
    );
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
    requestedFrom = from;
    requestedTo = to;
    requestedSourceId = sourceId;
    return [
      api.CalendarEvent(
        (builder) => builder
          ..id = 'event-1'
          ..sourceId = sourceId ?? 'source-1'
          ..externalUid = 'uid-1'
          ..title = 'Planning'
          ..description = 'Sprint planning'
          ..location = 'Room 1'
          ..startsAt = DateTime.utc(2026, 4, 22, 15)
          ..endsAt = DateTime.utc(2026, 4, 22, 16)
          ..allDay = false
          ..status = 'CONFIRMED'
          ..timezone = 'UTC'
          ..sourceDisplayName = 'Work',
      ),
    ];
  }

  @override
  Future<List<api.CalendarEvent>> getUpcomingCalendarEvents({
    int? limit,
  }) async {
    requestedLimit = limit;
    return [];
  }

  @override
  Future<api.CalendarEvent> getCalendarEventById({
    required String eventId,
  }) async {
    requestedEventId = eventId;
    return api.CalendarEvent(
      (builder) => builder
        ..id = eventId
        ..sourceId = 'source-1'
        ..externalUid = 'uid-$eventId'
        ..title = 'Review'
        ..description = 'Quarterly review'
        ..location = 'Room 2'
        ..startsAt = DateTime.utc(2026, 4, 23, 12)
        ..endsAt = DateTime.utc(2026, 4, 23, 13)
        ..allDay = false
        ..status = 'CONFIRMED'
        ..timezone = 'UTC'
        ..sourceDisplayName = 'Team Calendar',
    );
  }

  @override
  Future<api.CalendarSource> getCalendarSourceById({
    required String sourceId,
  }) async {
    requestedSourceId = sourceId;
    return api.CalendarSource(
      (builder) => builder
        ..id = sourceId
        ..userId = 'user-1'
        ..kind = 'ics_link'
        ..displayName = 'Team Calendar'
        ..category = 'Work'
        ..importMode = 'link'
        ..refreshState = 'synced',
    );
  }

  @override
  Future<List<api.CalendarSource>> getCalendarSources() async => [
    api.CalendarSource(
      (builder) => builder
        ..id = 'source-1'
        ..userId = 'user-1'
        ..kind = 'ics_link'
        ..displayName = 'Team Calendar'
        ..category = 'Work'
        ..importMode = 'link'
        ..refreshState = 'synced',
    ),
    api.CalendarSource(
      (builder) => builder
        ..id = 'source-2'
        ..userId = 'user-1'
        ..kind = 'ics_file'
        ..displayName = 'Imported Calendar'
        ..category = 'Personal'
        ..importMode = 'upload'
        ..refreshState = 'imported',
    ),
  ];

  @override
  Future<api.CalendarImportResponse> createLinkedCalendarSource({
    required String url,
    String? category,
    String? displayName,
  }) async {
    linkedUrl = url;
    linkedCategory = category;
    linkedDisplayName = displayName;
    return api.CalendarImportResponse(
      (builder) => builder
        ..source_.id = 'source-link-1'
        ..source_.userId = 'user-1'
        ..source_.kind = 'ics_link'
        ..source_.displayName = displayName ?? 'Linked'
        ..source_.category = category
        ..source_.importMode = 'link'
        ..source_.refreshState = 'synced'
        ..importedEventCount = 3,
    );
  }

  @override
  Future<api.CalendarSource> updateCalendarSource({
    required String sourceId,
    String? category,
    required String displayName,
  }) async {
    updatedSourceId = sourceId;
    updatedCategory = category;
    updatedDisplayName = displayName;
    return api.CalendarSource(
      (builder) => builder
        ..id = sourceId
        ..userId = 'user-1'
        ..kind = 'ics_link'
        ..displayName = displayName
        ..category = category
        ..importMode = 'link'
        ..refreshState = 'synced',
    );
  }

  @override
  Future<api.CalendarImportResponse> refreshCalendarSource({
    required String sourceId,
  }) async {
    refreshedSourceId = sourceId;
    return api.CalendarImportResponse(
      (builder) => builder
        ..source_.id = sourceId
        ..source_.userId = 'user-1'
        ..source_.kind = 'ics_link'
        ..source_.displayName = 'Linked'
        ..source_.category = 'Work'
        ..source_.importMode = 'link'
        ..source_.refreshState = 'synced'
        ..importedEventCount = 4,
    );
  }

  @override
  Future<void> deleteCalendarSource({required String sourceId}) async {
    deletedSource = true;
    deletedSourceId = sourceId;
  }
}

class ThrowingMessieCalendarSdk implements MessieCalendarSdk {
  @override
  Future<api.CalendarImportResponse> importCalendarSource({
    required List<int> bytes,
    required String filename,
    String? category,
    String? displayName,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/calendar/sources/import'),
      response: Response(
        requestOptions: RequestOptions(path: '/calendar/sources/import'),
        statusCode: 400,
        data: <String, dynamic>{
          'message':
              'Failed to import calendar source: calendar file contains no VEVENT entries',
        },
      ),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<void> deleteCalendarSource({required String sourceId}) =>
      throw UnimplementedError();

  @override
  Future<api.CalendarEvent> getCalendarEventById({required String eventId}) =>
      throw UnimplementedError();

  @override
  Future<List<api.CalendarEvent>> getCalendarEvents({
    DateTime? from,
    DateTime? to,
    String? sourceId,
    DateTime? cursor,
    String? direction,
    int? limit,
  }) => throw UnimplementedError();

  @override
  Future<api.CalendarSource> getCalendarSourceById({
    required String sourceId,
  }) => throw UnimplementedError();

  @override
  Future<List<api.CalendarSource>> getCalendarSources() =>
      throw UnimplementedError();

  @override
  Future<api.CalendarImportResponse> createLinkedCalendarSource({
    required String url,
    String? category,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<api.CalendarSource> updateCalendarSource({
    required String sourceId,
    String? category,
    required String displayName,
  }) => throw UnimplementedError();

  @override
  Future<api.CalendarImportResponse> refreshCalendarSource({
    required String sourceId,
  }) => throw UnimplementedError();

  @override
  Future<List<api.CalendarEvent>> getUpcomingCalendarEvents({int? limit}) =>
      throw UnimplementedError();
}

class ThrowingBytesMessieCalendarSdk implements MessieCalendarSdk {
  @override
  Future<api.CalendarImportResponse> importCalendarSource({
    required List<int> bytes,
    required String filename,
    String? category,
    String? displayName,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/calendar/sources/import'),
      response: Response(
        requestOptions: RequestOptions(path: '/calendar/sources/import'),
        statusCode: 400,
        data: Uint8List.fromList(
          '{"message":"Failed to import calendar source: calendar file contains no VEVENT entries"}'
              .codeUnits,
        ),
      ),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<void> deleteCalendarSource({required String sourceId}) =>
      throw UnimplementedError();

  @override
  Future<api.CalendarEvent> getCalendarEventById({required String eventId}) =>
      throw UnimplementedError();

  @override
  Future<List<api.CalendarEvent>> getCalendarEvents({
    DateTime? from,
    DateTime? to,
    String? sourceId,
    DateTime? cursor,
    String? direction,
    int? limit,
  }) => throw UnimplementedError();

  @override
  Future<api.CalendarSource> getCalendarSourceById({
    required String sourceId,
  }) => throw UnimplementedError();

  @override
  Future<List<api.CalendarSource>> getCalendarSources() =>
      throw UnimplementedError();

  @override
  Future<api.CalendarImportResponse> createLinkedCalendarSource({
    required String url,
    String? category,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<api.CalendarSource> updateCalendarSource({
    required String sourceId,
    String? category,
    required String displayName,
  }) => throw UnimplementedError();

  @override
  Future<api.CalendarImportResponse> refreshCalendarSource({
    required String sourceId,
  }) => throw UnimplementedError();

  @override
  Future<List<api.CalendarEvent>> getUpcomingCalendarEvents({int? limit}) =>
      throw UnimplementedError();
}

void main() {
  group('MessieCalendarService', () {
    test('maps import upload into generated calendar client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      final result = await service.importCalendarSource(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        file: XFile.fromData(
          Uint8List.fromList(const [1, 2, 3, 4]),
          name: 'calendar.ics',
          mimeType: 'text/calendar',
        ),
        category: 'Work',
        displayName: 'Work',
      );

      expect(sdk.importedBytes, [1, 2, 3, 4]);
      expect(sdk.importedFilename, 'calendar.ics');
      expect(sdk.importedCategory, 'Work');
      expect(sdk.importedDisplayName, 'Work');
      expect(result.source.category, 'Work');
      expect(result.source.displayName, 'Work');
      expect(result.importedEventCount, 2);
    });

    test('normalizes range queries to UTC', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      await service.getCalendarEvents(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        from: DateTime(2026, 4, 22, 10),
        to: DateTime(2026, 4, 23, 18),
        sourceId: 'source-1',
      );

      expect(sdk.requestedSourceId, 'source-1');
      expect(sdk.requestedFrom?.isUtc, isTrue);
      expect(sdk.requestedTo?.isUtc, isTrue);
    });

    test('passes upcoming limit through to generated client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      await service.getUpcomingCalendarEvents(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        limit: 7,
      );

      expect(sdk.requestedLimit, 7);
    });

    test('loads calendar sources through generated client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      final sources = await service.getCalendarSources(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
      );

      expect(sources, hasLength(2));
      expect(sources.first.displayName, 'Team Calendar');
      expect(sources.first.category, 'Work');
      expect(sources.last.importMode, 'upload');
    });

    test('creates linked calendar sources through generated client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      final result = await service.createLinkedCalendarSource(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        url: 'https://calendar.example.com/feed.ics',
        category: 'Work',
        displayName: 'Team Calendar',
      );

      expect(sdk.linkedUrl, 'https://calendar.example.com/feed.ics');
      expect(sdk.linkedCategory, 'Work');
      expect(sdk.linkedDisplayName, 'Team Calendar');
      expect(result.source.category, 'Work');
      expect(result.source.importMode, 'link');
      expect(result.importedEventCount, 3);
    });

    test('updates calendar source names through generated client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      final result = await service.updateCalendarSource(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        sourceId: 'source-link-1',
        category: 'Ops',
        displayName: 'Renamed',
      );

      expect(sdk.updatedSourceId, 'source-link-1');
      expect(sdk.updatedCategory, 'Ops');
      expect(sdk.updatedDisplayName, 'Renamed');
      expect(result.category, 'Ops');
      expect(result.displayName, 'Renamed');
    });

    test('loads a calendar source by id through generated client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      final source = await service.getCalendarSourceById(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        sourceId: 'source-link-1',
      );

      expect(sdk.requestedSourceId, 'source-link-1');
      expect(source.category, 'Work');
      expect(source.displayName, 'Team Calendar');
      expect(source.importMode, 'link');
    });

    test('refreshes calendar sources through generated client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      final result = await service.refreshCalendarSource(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        sourceId: 'source-link-1',
      );

      expect(sdk.refreshedSourceId, 'source-link-1');
      expect(result.importedEventCount, 4);
    });

    test('loads a calendar event by id through generated client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      final event = await service.getCalendarEventById(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        eventId: 'event-42',
      );

      expect(sdk.requestedEventId, 'event-42');
      expect(event.title, 'Review');
      expect(event.sourceDisplayName, 'Team Calendar');
    });

    test('deletes calendar sources through generated client', () async {
      final sdk = RecordingMessieCalendarSdk();
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      await service.deleteCalendarSource(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        sourceId: 'source-link-1',
      );

      expect(sdk.deletedSource, isTrue);
      expect(sdk.deletedSourceId, 'source-link-1');
    });

    test('surfaces backend message for import failures', () async {
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) =>
            ThrowingMessieCalendarSdk(),
      );

      expect(
        () => service.importCalendarSource(
          apiBaseUrl: 'http://localhost:8080/api/v1',
          jwt: 'jwt',
          file: XFile.fromData(
            Uint8List.fromList(const [1, 2, 3, 4]),
            name: 'calendar.ics',
            mimeType: 'text/calendar',
          ),
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('calendar file contains no VEVENT entries'),
          ),
        ),
      );
    });

    test('surfaces backend message for byte payload import failures', () async {
      final service = MessieCalendarService(
        sdkFactory: ({required apiBaseUrl, required jwt}) =>
            ThrowingBytesMessieCalendarSdk(),
      );

      expect(
        () => service.importCalendarSource(
          apiBaseUrl: 'http://localhost:8080/api/v1',
          jwt: 'jwt',
          file: XFile.fromData(
            Uint8List.fromList(const [1, 2, 3, 4]),
            name: 'calendar.ics',
            mimeType: 'text/calendar',
          ),
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('calendar file contains no VEVENT entries'),
          ),
        ),
      );
    });
  });
}
