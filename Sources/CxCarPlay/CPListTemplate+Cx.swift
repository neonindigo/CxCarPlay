#if canImport(CarPlay)
import CarPlay
import Combine

extension CxCarPlayExtension where Base: CPListTemplate {
    /// Binds a publisher of sections to this template, updating it on each emission.
    /// Injects selection handlers into each CPListItem so taps publish to `itemSelected`.
    /// - Returns: AnyCancellable — cancel to stop updates. Store it to keep the binding alive.
    public func bind(sections: some Publisher<[CPListSection], Never>) -> AnyCancellable {
        // TODO: implement in feat/list
        fatalError("stub")
    }

    /// Emits a Selection each time the user taps a bound list item.
    /// Only emits for items bound via `bind(sections:)`.
    public var itemSelected: AnyPublisher<Selection, Never> {
        // TODO: implement in feat/list
        fatalError("stub")
    }
}
#endif
