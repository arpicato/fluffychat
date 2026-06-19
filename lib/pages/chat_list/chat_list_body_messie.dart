// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/chat_list_calendar_item.dart';
import 'package:fluffychat/pages/chat_list/chat_list_entries.dart';
import 'package:fluffychat/pages/chat_list/chat_list_focus_item.dart';
import 'package:fluffychat/pages/chat_list/chat_list_item.dart';
import 'package:fluffychat/pages/chat_list/chat_list_todo_item.dart';
import 'package:fluffychat/pages/chat_list/dummy_chat_list_item.dart';
import 'package:fluffychat/pages/chat_list/search_title.dart';
import 'package:fluffychat/pages/chat_list/space_view.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/utils/stream_extension.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/public_room_dialog.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../config/themes.dart';
import '../../widgets/adaptive_dialogs/user_dialog.dart';
import '../../widgets/matrix.dart';
import 'chat_list_header.dart';

class ChatListViewBody extends StatelessWidget {
  final ChatListController controller;
  final VoidCallback? openDrawer;

  const ChatListViewBody(this.controller, {this.openDrawer, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeRoute = GoRouterState.of(context).uri.path;

    final client = Matrix.of(context).client;
    final activeSpace = controller.activeSpaceId;
    if (activeSpace != null) {
      return SpaceView(
        key: ValueKey(activeSpace),
        spaceId: activeSpace,
        onBack: controller.clearActiveSpace,
        onChatTab: controller.onChatTap,
        activeChat: controller.activeChat,
      );
    }
    final spaces = client.rooms.where((r) => r.isSpace);
    final spaceDelegateCandidates = <String, Room>{};
    for (final space in spaces) {
      for (final spaceChild in space.spaceChildren) {
        final roomId = spaceChild.roomId;
        if (roomId == null) continue;
        spaceDelegateCandidates[roomId] = space;
      }
    }

    final publicRooms = controller.roomSearchResult?.chunk
        .where((room) => room.roomType != 'm.space')
        .toList();
    final publicSpaces = controller.roomSearchResult?.chunk
        .where((room) => room.roomType == 'm.space')
        .toList();
    final userSearchResult = controller.userSearchResult;
    const dummyChatCount = 4;
    final filter = controller.searchController.text.toLowerCase();
    return StreamBuilder(
      key: ValueKey(client.userID.toString()),
      stream: client.onSync.stream
          .where((s) => s.hasRoomUpdate)
          .rateLimit(const Duration(seconds: 1)),
      builder: (context, _) {
        final rooms = controller.filteredRooms
            .where(
              (room) =>
                  !AppSettings.hideRoomsInSpaces.value ||
                  spaceDelegateCandidates[room.id] == null,
            )
            .toList();
        final includeTodoLists =
            !controller.isSearchMode &&
            controller.activeFilter == ActiveFilter.allChats;
        final visibleTodoLists = includeTodoLists
            ? controller.todoLists.where((todoList) {
                if (filter.isEmpty) return true;
                final title = todoList.title.toLowerCase();
                final description = todoList.description.toLowerCase();
                return title.contains(filter) || description.contains(filter);
              }).toList()
            : const <MessieTodoList>[];
        final rawCalendarEvents = includeTodoLists
            ? (controller.upcomingCalendarEvents
                  .where((event) {
                    final now = DateTime.now().toUtc();
                    final end = now.add(const Duration(days: 7));
                    if (event.startsAt.isAfter(end) ||
                        event.endsAt.isBefore(now)) {
                      return false;
                    }
                    if (filter.isEmpty) return true;
                    final title = event.title.toLowerCase();
                    final description = event.description.toLowerCase();
                    final location = event.location.toLowerCase();
                    final source = event.sourceDisplayName.toLowerCase();
                    return title.contains(filter) ||
                        description.contains(filter) ||
                        location.contains(filter) ||
                        source.contains(filter);
                  })
                  .take(2)
                  .toList()
                ..sort((a, b) => a.startsAt.compareTo(b.startsAt)))
            : const <MessieCalendarEvent>[];
        final visibleCalendarEvents = includeTodoLists &&
                rawCalendarEvents.length > 1 &&
                !(_isEventToday(rawCalendarEvents[0]) &&
                    _isEventToday(rawCalendarEvents[1]))
            ? [rawCalendarEvents[0]]
            : rawCalendarEvents;
        final timelineEntries = <ChatListEntry>[
          ...rooms.map(ChatListEntry.room),
          ...visibleTodoLists.map(ChatListEntry.todo),
        ]..sort((a, b) {
          // Preserve SDK room ordering (respects pins, unread, low-priority)
          // Interleave pinned todos with pinned rooms first, then sort the rest by time.
          final aIsRoom = a is RoomChatListEntry;
          final bIsRoom = b is RoomChatListEntry;
          final aRoom = aIsRoom ? a.room : null;
          final bRoom = bIsRoom ? b.room : null;
          final aPin = aRoom?.isFavourite == true;
          final bPin = bRoom?.isFavourite == true;
          final aTodoPinned = a is TodoChatListEntry &&
              controller.isTodoListPinned(a.todoList.id);
          final bTodoPinned = b is TodoChatListEntry &&
              controller.isTodoListPinned(b.todoList.id);
          final aPinned = aPin || aTodoPinned;
          final bPinned = bPin || bTodoPinned;

          if (aPinned && !bPinned) return -1;
          if (bPinned && !aPinned) return 1;

          // Among pinned rooms, preserve SDK order. Pinned todo lists sort by activity.
          if (aPinned && bPinned) {
            if (aPin && bPin) {
              return rooms.indexOf(aRoom!).compareTo(rooms.indexOf(bRoom!));
            }
            return b.sortTime.compareTo(a.sortTime);
          }

          // Non-pinned: sort by time
          return b.sortTime.compareTo(a.sortTime);
        });
        final calendarEntries = <ChatListEntry>[
          ...visibleCalendarEvents.map(ChatListEntry.calendar),
        ]..sort((a, b) => a.sortTime.compareTo(b.sortTime));
        final entries = <ChatListEntry>[
          ...calendarEntries,
          if (calendarEntries.isNotEmpty && timelineEntries.isNotEmpty)
            const DividerChatListEntry(),
          ...timelineEntries,
        ];

        // Navigable entries = everything except dividers
        final navigableEntries = entries
            .where((e) => e is! DividerChatListEntry)
            .toList();
        controller.navigableEntries = navigableEntries;

        return SafeArea(
            child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              ChatListHeader(controller: controller, openDrawer: openDrawer),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (controller.isSearchMode) ...[
                    SearchTitle(
                      title: L10n.of(context).publicRooms,
                      icon: const Icon(Icons.explore_outlined),
                    ),
                    PublicRoomsHorizontalList(publicRooms: publicRooms),
                    SearchTitle(
                      title: L10n.of(context).publicSpaces,
                      icon: const Icon(Icons.workspaces_outlined),
                    ),
                    PublicRoomsHorizontalList(publicRooms: publicSpaces),
                    SearchTitle(
                      title: L10n.of(context).users,
                      icon: const Icon(Icons.group_outlined),
                    ),
                    AnimatedContainer(
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(),
                      height:
                          userSearchResult == null ||
                              userSearchResult.results.isEmpty
                          ? 0
                          : 106,
                      duration: FluffyThemes.animationDuration,
                      curve: FluffyThemes.animationCurve,
                      child: userSearchResult == null
                          ? null
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: userSearchResult.results.length,
                              itemBuilder: (context, i) => _SearchItem(
                                title:
                                    userSearchResult.results[i].displayName ??
                                    userSearchResult
                                        .results[i]
                                        .userId
                                        .localpart ??
                                    L10n.of(context).unknownDevice,
                                avatar: userSearchResult.results[i].avatarUrl,
                                onPressed: () => UserDialog.show(
                                  context: context,
                                  profile: userSearchResult.results[i],
                                ),
                              ),
                            ),
                    ),
                  ],
                  if (client.rooms.isNotEmpty && !controller.isSearchMode)
                    SizedBox(
                      height: 64,
                      child: ListView(
                        padding: const EdgeInsets.all(12.0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...ActiveFilter.values
                              .where((filter) => filter != ActiveFilter.tag)
                              .map(
                                (filter) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: FilterChip(
                                    selected: filter == controller.activeFilter,
                                    onSelected: (_) => controller
                                        .setActiveFilter(filter, null),
                                    label: Text(
                                      filter.toLocalizedString(context),
                                    ),
                                  ),
                                ),
                              ),
                          ...controller.roomTags.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: FilterChip(
                                selected: entry.key == controller.activeTag,
                                onSelected: (_) => controller.setActiveFilter(
                                  ActiveFilter.tag,
                                  entry.key,
                                ),
                                label: Text(entry.key.replaceFirst('u.', '')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (controller.isSearchMode)
                    SearchTitle(
                      title: L10n.of(context).chats,
                      icon: const Icon(Icons.forum_outlined),
                    ),
                  if (client.prevBatch != null &&
                      entries.isEmpty &&
                      !controller.isSearchMode &&
                      !controller.isLoadingTodoLists) ...[
                    Column(
                      mainAxisAlignment: .center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Column(
                              mainAxisSize: .min,
                              children: [
                                DummyChatListItem(opacity: 0.5, animate: false),
                                DummyChatListItem(opacity: 0.3, animate: false),
                              ],
                            ),
                            Icon(
                              CupertinoIcons.chat_bubble_text_fill,
                              size: 128,
                              color: theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            client.rooms.isEmpty && controller.todoLists.isEmpty
                                ? L10n.of(context).noChatsFoundHere
                                : L10n.of(context).noMoreChatsFound,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ]),
              ),
              if (client.prevBatch == null)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => DummyChatListItem(
                      opacity: (dummyChatCount - i) / dummyChatCount,
                      animate: true,
                    ),
                    childCount: dummyChatCount,
                  ),
                ),
              if (client.prevBatch != null)
                SliverList.builder(
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int i) {
                    final entry = entries[i];
                    if (entry is DividerChatListEntry) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Divider(
                          color: theme.colorScheme.outlineVariant,
                          height: 1,
                        ),
                      );
                    }
                    // Count navigable items before this one to get the correct index.
                    var navIndex = 0;
                    for (var j = 0; j < i; j++) {
                      if (entries[j] is! DividerChatListEntry) navIndex++;
                    }
                    return ChatListFocusItem(
                      order: navIndex,
                      controller: controller,
                      onFocused: () {
                        controller.focusedChatListEntry = entry;
                        controller.focusedChatListIndex = navIndex;
                      },
                      child: switch (entry) {
                        RoomChatListEntry(:final room) => ChatListItem(
                          room,
                          presentation: controller.bridgePresentationForRoom(room),
                          space: spaceDelegateCandidates[room.id],
                          key: Key('chat_list_item_${room.id}'),
                          filter: filter,
                          onTap: () => controller.onChatTap(room),
                          onLongPress: (context) => controller.chatContextAction(
                            room,
                            context,
                            spaceDelegateCandidates[room.id],
                          ),
                          activeChat: controller.activeChat == room.id,
                        ),
                        TodoChatListEntry(:final todoList) => ChatListTodoItem(
                          key: Key('chat_list_todo_${todoList.id}'),
                          todoList: todoList,
                          pinned: controller.isTodoListPinned(todoList.id),
                          onShowContextMenu: (context) => controller
                              .todoListContextAction(todoList, context),
                          active:
                              activeRoute == '/rooms/todos/${todoList.id}' ||
                              activeRoute.startsWith('/rooms/todos/${todoList.id}/'),
                          onTap: () => context.push(
                            '/rooms/todos/${todoList.id}',
                            extra: <String, Object?>{'title': todoList.title, 'description': todoList.description},
                          ),
                        ),
                        CalendarChatListEntry(:final event) => ChatListCalendarItem(
                          key: Key('chat_list_calendar_${event.id}'),
                          event: event,
                          active:
                              activeRoute == '/rooms/calendar/events/${event.id}' ||
                              activeRoute.startsWith('/rooms/calendar/events/${event.id}/'),
                          onTap: () => context.push(
                            '/rooms/calendar/events/${event.id}',
                            extra: <String, Object?>{'title': event.title, 'sourceDisplayName': event.sourceDisplayName},
                          ),
                        ),
                        DividerChatListEntry() => const SizedBox.shrink(),
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class PublicRoomsHorizontalList extends StatelessWidget {
  const PublicRoomsHorizontalList({super.key, required this.publicRooms});

  final List<PublishedRoomsChunk>? publicRooms;

  @override
  Widget build(BuildContext context) {
    final publicRooms = this.publicRooms;
    return AnimatedContainer(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      height: publicRooms == null || publicRooms.isEmpty ? 0 : 106,
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
      child: publicRooms == null
          ? null
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: publicRooms.length,
              itemBuilder: (context, i) => _SearchItem(
                title:
                    publicRooms[i].name ??
                    publicRooms[i].canonicalAlias?.localpart ??
                    L10n.of(context).group,
                avatar: publicRooms[i].avatarUrl,
                onPressed: () => showAdaptiveDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (c) => PublicRoomDialog(
                    roomAlias:
                        publicRooms[i].canonicalAlias ?? publicRooms[i].roomId,
                    chunk: publicRooms[i],
                  ),
                ),
              ),
            ),
    );
  }
}

class _SearchItem extends StatelessWidget {
  final String title;
  final Uri? avatar;
  final void Function() onPressed;

  const _SearchItem({
    required this.title,
    this.avatar,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onPressed,
    child: SizedBox(
      width: 84,
      child: Column(
        mainAxisSize: .min,
        children: [
          const SizedBox(height: 8),
          Avatar(mxContent: avatar, name: title),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    ),
  );
}

bool _isEventToday(MessieCalendarEvent event) {
  final localStart = event.startsAt.toLocal();
  final now = DateTime.now().toLocal();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  return localStart.isBefore(endOfDay) &&
      event.endsAt.toLocal().isAfter(startOfDay);
}
