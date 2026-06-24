# CxCarPlay

A Combine-native reactive layer for CarPlay templates. Provides data binding and interaction event publishers for `CPListTemplate`, `CPGridTemplate`, `CPTabBarTemplate`, and `CPTemplate`. Part of the Cx ecosystem.

## Language

**Session**
The period between CarPlay connecting (`CPTemplateApplicationSceneDelegate.didConnect`) and disconnecting (`didDisconnect`). CxCarPlay has no opinion on session management — that is the caller's responsibility.
_Avoid_: connection, lifecycle

**Binding**
An active `AnyCancellable` subscription that drives a CarPlay template's content from a Combine publisher. While the binding is alive, emissions from the publisher update the template. Cancelling the binding stops updates.
_Avoid_: subscription, sink, data source

**Selection**
A value emitted when a user taps a list item. Carries the selected `CPListItem` and a `complete()` method that must be called when the app finishes handling the selection. CarPlay freezes the list UI until `complete()` is called. Warns in debug builds if `complete()` is never called.
_Avoid_: tap, item event, list event

**Section Publisher**
A `Publisher` of `[CPListSection]` bound to a `CPListTemplate` via `cx.bind(sections:)`. When bound, CxCarPlay injects selection handlers into each `CPListItem` in each section so that taps publish to `cx.itemSelected`.
_Avoid_: data source, section stream

**Tab Publisher**
A `Publisher` of `[CPTemplate]` bound to a `CPTabBarTemplate` via `cx.bind(templates:)`. Emissions call `CPTabBarTemplate.updateTemplates(_:)`.
_Avoid_: template stream

## Reactive surface by template

**`CPListTemplate.cx`**
- `bind(sections: some Publisher<[CPListSection], Never>) -> AnyCancellable` — drives section updates; injects item handlers
- `itemSelected: AnyPublisher<Selection, Never>` — emits when a user taps a bound list item

**`CPGridTemplate.cx`**
- No reactive taps (CPGridButton uses closure-based handlers; not in scope)
- Future: title/subtitle binding if needed

**`CPTabBarTemplate.cx`**
- `bind(templates: some Publisher<[CPTemplate], Never>) -> AnyCancellable` — drives tab updates
- No `tabSelected` in v1 (requires delegate installation — out of scope)

**`CPTemplate.cx`** (base)
- No reactive surface in v1 (lifecycle events not in scope)

## Relationships

- A **Binding** keeps a **Section Publisher** or **Tab Publisher** alive; cancelling the `AnyCancellable` stops updates to the template
- A **Selection** is only emitted when the template has an active **Binding**; bypassing binding (manual `updateSections`) produces no selections
- A **Selection** carries a `CPListItem` and a `complete()` callback; the caller is responsible for calling `complete()` before the next user interaction is needed

## Example dialogue

> **Dev:** "Do I need to call `complete()` on every selection, even if I'm just navigating?"
> **Domain expert:** "Yes — CarPlay freezes the list UI until `complete()` is called. For simple navigation, call it immediately. For async work (fetching data, loading audio), call it once the work finishes and the template is ready."

> **Dev:** "Can I update sections without using `bind`?"
> **Domain expert:** "You can call `template.updateSections` directly, but those items won't have **Selection** handlers — `cx.itemSelected` will never emit for them. If you need selections, you must use a **Binding**."

## Flagged ambiguities

- "tab selection" initially considered — resolved: requires `CPTabBarTemplateDelegate` installation which is out of scope for v1; cut entirely
- "grid taps" initially considered — resolved: `CPGridButton` uses closure handlers, not delegates; reactive grid taps are out of scope for v1
- "lifecycle events" initially considered — resolved: excluded from v1; require a coordinator object (`CxCarPlaySession`) which adds scope beyond data binding and interaction
