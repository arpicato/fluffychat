import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:matrix/matrix.dart';

sealed class ChatListEntry {
  const ChatListEntry();

  factory ChatListEntry.room(Room room) = RoomChatListEntry;
  factory ChatListEntry.todo(MessieTodoList todoList) = TodoChatListEntry;
  factory ChatListEntry.calendar(MessieCalendarEvent event) =
      CalendarChatListEntry;

  DateTime get sortTime;
}

class RoomChatListEntry extends ChatListEntry {
  const RoomChatListEntry(this.room);

  final Room room;

  @override
  DateTime get sortTime => room.latestEventReceivedTime;
}

class TodoChatListEntry extends ChatListEntry {
  const TodoChatListEntry(this.todoList);

  final MessieTodoList todoList;

  @override
  DateTime get sortTime => todoList.activityAt ?? DateTime.fromMillisecondsSinceEpoch(0);
}

class CalendarChatListEntry extends ChatListEntry {
  const CalendarChatListEntry(this.event);

  final MessieCalendarEvent event;

  @override
  DateTime get sortTime => event.startsAt;
}

class DividerChatListEntry extends ChatListEntry {
  const DividerChatListEntry();

  @override
  DateTime get sortTime => DateTime.fromMillisecondsSinceEpoch(0);
}
