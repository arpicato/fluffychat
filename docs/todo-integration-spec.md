# Todo Integration Spec

## Status

This document defines the intended direction for todo integration in the `fluffychat` fork while `messie-messenger` remains the backend and UX reference.

Current implementation status:

- Matrix OpenID -> backend JWT exchange works.
- FluffyChat can fetch and render todo lists from Messie.
- The current `/rooms/settings/todos` page is a temporary spike and not the final product UX.

## Product Direction

`fluffychat` is intended to replace the `messie-messenger` client, not merely embed a debug view of Messie APIs. The final todo experience should therefore follow Messie's product model rather than stop at a read-only settings page.

Messie reference sources:

- `messie-messenger/docs/ui-features.md`
- `messie-messenger/docs/architecture.md`
- `messie-messenger/docs/roadmap/todo.md`
- `messie-messenger/frontend/README.md`

## Target Experience

Todos should become a first-class workspace feature in FluffyChat with these expectations:

- Lists are visible as meaningful user-facing entities, not just raw API records.
- Opening a list leads to a detail surface, not a dead-end summary card.
- List title and description can be viewed and edited.
- Items can be created, updated, reordered, completed, and deleted.
- Collaborators are supported as the backend contract allows.
- Empty, loading, and error states feel intentional and productized.

## UX Shape

The preferred long-term information architecture is to merge todos into the main workspace/chat list surface rather than hide them only inside Settings.

The current settings entry point is acceptable as a temporary home and fallback route, but it should not be treated as the final primary entry point.

Likely end-state expectations:

- A todo/workspace entry in the main chat list or equivalent left-hand navigation.
- A todo list overview surface in FluffyChat.
- A todo detail surface for one list.
- A clear create affordance for new lists and items.
- Mobile-friendly interactions adapted from Messie's intent rather than copied literally.

For now, we should treat these as required capabilities:

1. List overview
2. Open list details
3. Create/update/delete list
4. Item CRUD and completion
5. Collaborator visibility and basic management

## Transitional Plan

Near-term rollout can happen in stages:

1. Keep `/rooms/settings/todos` working as the safe fallback route.
2. Add a primary todo entry in the main chat/workspace list.
3. Route that entry to the existing todo overview.
4. Replace the overview with richer list/detail flows over time.

## Non-Goals For Spike V1

These are intentionally out of scope for the current spike unless explicitly requested:

- Full unified timeline integration
- Calendar integration for due dates
- Offline-first conflict resolution
- Live realtime collaboration
- Attachments and comments on todo items

## Engineering Guidance

While building toward the target experience:

- Prefer backend-compatible adapters in FluffyChat for casing or response-shape mismatches.
- Keep Messie backend APIs as the source of truth for todo capabilities.
- Avoid overfitting UI decisions to the temporary settings-page prototype.
- Remove temporary debug-only UI once product flows are in place.

## Recommended Implementation Order

1. Stabilize list overview in FluffyChat.
2. Add list detail route/page.
3. Add item fetching and rendering.
4. Add create/edit/delete flows for lists and items.
5. Add collaborators.
6. Revisit broader placement such as unified workspace/timeline integration.

## Open Questions

- Should todos ultimately live in Settings, a dedicated workspace section, or both?
- How closely should FluffyChat mirror Messie's split-pane desktop behavior on wide screens?
- What is the minimum viable collaborator experience for the first production-ready version?
- When should realtime updates replace manual refresh/pull-to-refresh behavior?
