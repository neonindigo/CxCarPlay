# Selection is a value type, not a raw callback tuple

`CPListTemplate` item selection is exposed as a `Selection` struct carrying the `CPListItem` and a `complete()` method, rather than emitting a raw `(CPListItem, () -> Void)` tuple.

CarPlay requires that the completion handler passed to `CPListTemplateDelegate.listTemplate(_:didSelect:completionHandler:)` (and forwarded as `Selection.complete()`) is always called. A raw tuple gives the caller no structural reminder of this obligation. `Selection` makes `complete()` a named method on the value, documents the contract in the type, and in debug builds can assert if `complete()` is never called before `Selection` is deallocated. A tuple would have none of these properties and would expose callers to a silent UI-freeze bug if the handler is dropped.
