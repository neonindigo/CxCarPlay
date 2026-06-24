#if canImport(CarPlay)
import CarPlay
import Foundation

/// Emitted when a user taps a list item. Call `complete()` when your app finishes handling
/// the selection — CarPlay freezes the list UI until it is called.
///
/// `Selection` is `@MainActor` because CarPlay selection callbacks always fire on the main
/// thread, and `complete()` must resume on the main thread to unblock the CarPlay UI safely.
@MainActor
public final class Selection {
    /// The item the user tapped.
    public let item: CPListItem

    private let completionHandler: () -> Void
    private var completed = false

    init(item: CPListItem, completionHandler: @escaping () -> Void) {
        self.item = item
        self.completionHandler = completionHandler
    }

    /// Call this when your app has finished handling the selection.
    /// CarPlay unblocks the list UI after this is called.
    public func complete() {
        guard !completed else { return }
        completed = true
        completionHandler()
    }

    deinit {
        // Debug warning if complete() was never called
        assert(completed, "CxCarPlay: Selection for item '\(item.text ?? "(no text)")' was deallocated without calling complete(). CarPlay UI may remain frozen.")
        if !completed { completionHandler() }  // safety: always unblock CarPlay
    }
}
#endif
