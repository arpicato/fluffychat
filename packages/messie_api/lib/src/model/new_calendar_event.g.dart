// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_calendar_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NewCalendarEvent extends NewCalendarEvent {
  @override
  final String sourceId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? location;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final bool? allDay;

  factory _$NewCalendarEvent(
          [void Function(NewCalendarEventBuilder)? updates]) =>
      (NewCalendarEventBuilder()..update(updates))._build();

  _$NewCalendarEvent._(
      {required this.sourceId,
      required this.title,
      this.description,
      this.location,
      required this.startTime,
      required this.endTime,
      this.allDay})
      : super._();
  @override
  NewCalendarEvent rebuild(void Function(NewCalendarEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NewCalendarEventBuilder toBuilder() =>
      NewCalendarEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NewCalendarEvent &&
        sourceId == other.sourceId &&
        title == other.title &&
        description == other.description &&
        location == other.location &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        allDay == other.allDay;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourceId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, startTime.hashCode);
    _$hash = $jc(_$hash, endTime.hashCode);
    _$hash = $jc(_$hash, allDay.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NewCalendarEvent')
          ..add('sourceId', sourceId)
          ..add('title', title)
          ..add('description', description)
          ..add('location', location)
          ..add('startTime', startTime)
          ..add('endTime', endTime)
          ..add('allDay', allDay))
        .toString();
  }
}

class NewCalendarEventBuilder
    implements Builder<NewCalendarEvent, NewCalendarEventBuilder> {
  _$NewCalendarEvent? _$v;

  String? _sourceId;
  String? get sourceId => _$this._sourceId;
  set sourceId(String? sourceId) => _$this._sourceId = sourceId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _location;
  String? get location => _$this._location;
  set location(String? location) => _$this._location = location;

  DateTime? _startTime;
  DateTime? get startTime => _$this._startTime;
  set startTime(DateTime? startTime) => _$this._startTime = startTime;

  DateTime? _endTime;
  DateTime? get endTime => _$this._endTime;
  set endTime(DateTime? endTime) => _$this._endTime = endTime;

  bool? _allDay;
  bool? get allDay => _$this._allDay;
  set allDay(bool? allDay) => _$this._allDay = allDay;

  NewCalendarEventBuilder() {
    NewCalendarEvent._defaults(this);
  }

  NewCalendarEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourceId = $v.sourceId;
      _title = $v.title;
      _description = $v.description;
      _location = $v.location;
      _startTime = $v.startTime;
      _endTime = $v.endTime;
      _allDay = $v.allDay;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NewCalendarEvent other) {
    _$v = other as _$NewCalendarEvent;
  }

  @override
  void update(void Function(NewCalendarEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NewCalendarEvent build() => _build();

  _$NewCalendarEvent _build() {
    final _$result = _$v ??
        _$NewCalendarEvent._(
          sourceId: BuiltValueNullFieldError.checkNotNull(
              sourceId, r'NewCalendarEvent', 'sourceId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'NewCalendarEvent', 'title'),
          description: description,
          location: location,
          startTime: BuiltValueNullFieldError.checkNotNull(
              startTime, r'NewCalendarEvent', 'startTime'),
          endTime: BuiltValueNullFieldError.checkNotNull(
              endTime, r'NewCalendarEvent', 'endTime'),
          allDay: allDay,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
