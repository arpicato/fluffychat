// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CalendarEvent extends CalendarEvent {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String externalUid;
  @override
  final String title;
  @override
  final String description;
  @override
  final String location;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final bool allDay;
  @override
  final String status;
  @override
  final String timezone;
  @override
  final String? recurrenceSummary;
  @override
  final String sourceDisplayName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$CalendarEvent([void Function(CalendarEventBuilder)? updates]) =>
      (CalendarEventBuilder()..update(updates))._build();

  _$CalendarEvent._(
      {required this.id,
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
      this.recurrenceSummary,
      required this.sourceDisplayName,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  CalendarEvent rebuild(void Function(CalendarEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CalendarEventBuilder toBuilder() => CalendarEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CalendarEvent &&
        id == other.id &&
        sourceId == other.sourceId &&
        externalUid == other.externalUid &&
        title == other.title &&
        description == other.description &&
        location == other.location &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        allDay == other.allDay &&
        status == other.status &&
        timezone == other.timezone &&
        recurrenceSummary == other.recurrenceSummary &&
        sourceDisplayName == other.sourceDisplayName &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sourceId.hashCode);
    _$hash = $jc(_$hash, externalUid.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, allDay.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, recurrenceSummary.hashCode);
    _$hash = $jc(_$hash, sourceDisplayName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CalendarEvent')
          ..add('id', id)
          ..add('sourceId', sourceId)
          ..add('externalUid', externalUid)
          ..add('title', title)
          ..add('description', description)
          ..add('location', location)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('allDay', allDay)
          ..add('status', status)
          ..add('timezone', timezone)
          ..add('recurrenceSummary', recurrenceSummary)
          ..add('sourceDisplayName', sourceDisplayName)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CalendarEventBuilder
    implements Builder<CalendarEvent, CalendarEventBuilder> {
  _$CalendarEvent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _sourceId;
  String? get sourceId => _$this._sourceId;
  set sourceId(String? sourceId) => _$this._sourceId = sourceId;

  String? _externalUid;
  String? get externalUid => _$this._externalUid;
  set externalUid(String? externalUid) => _$this._externalUid = externalUid;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _location;
  String? get location => _$this._location;
  set location(String? location) => _$this._location = location;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  bool? _allDay;
  bool? get allDay => _$this._allDay;
  set allDay(bool? allDay) => _$this._allDay = allDay;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  String? _recurrenceSummary;
  String? get recurrenceSummary => _$this._recurrenceSummary;
  set recurrenceSummary(String? recurrenceSummary) =>
      _$this._recurrenceSummary = recurrenceSummary;

  String? _sourceDisplayName;
  String? get sourceDisplayName => _$this._sourceDisplayName;
  set sourceDisplayName(String? sourceDisplayName) =>
      _$this._sourceDisplayName = sourceDisplayName;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CalendarEventBuilder() {
    CalendarEvent._defaults(this);
  }

  CalendarEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _sourceId = $v.sourceId;
      _externalUid = $v.externalUid;
      _title = $v.title;
      _description = $v.description;
      _location = $v.location;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _allDay = $v.allDay;
      _status = $v.status;
      _timezone = $v.timezone;
      _recurrenceSummary = $v.recurrenceSummary;
      _sourceDisplayName = $v.sourceDisplayName;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CalendarEvent other) {
    _$v = other as _$CalendarEvent;
  }

  @override
  void update(void Function(CalendarEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CalendarEvent build() => _build();

  _$CalendarEvent _build() {
    final _$result = _$v ??
        _$CalendarEvent._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'CalendarEvent', 'id'),
          sourceId: BuiltValueNullFieldError.checkNotNull(
              sourceId, r'CalendarEvent', 'sourceId'),
          externalUid: BuiltValueNullFieldError.checkNotNull(
              externalUid, r'CalendarEvent', 'externalUid'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'CalendarEvent', 'title'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'CalendarEvent', 'description'),
          location: BuiltValueNullFieldError.checkNotNull(
              location, r'CalendarEvent', 'location'),
          startsAt: BuiltValueNullFieldError.checkNotNull(
              startsAt, r'CalendarEvent', 'startsAt'),
          endsAt: BuiltValueNullFieldError.checkNotNull(
              endsAt, r'CalendarEvent', 'endsAt'),
          allDay: BuiltValueNullFieldError.checkNotNull(
              allDay, r'CalendarEvent', 'allDay'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'CalendarEvent', 'status'),
          timezone: BuiltValueNullFieldError.checkNotNull(
              timezone, r'CalendarEvent', 'timezone'),
          recurrenceSummary: recurrenceSummary,
          sourceDisplayName: BuiltValueNullFieldError.checkNotNull(
              sourceDisplayName, r'CalendarEvent', 'sourceDisplayName'),
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
