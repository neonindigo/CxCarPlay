#if canImport(CarPlay)
import CarPlay
import Combine

extension CxCarPlayExtension where Base: CPTabBarTemplate {
    /// Binds a publisher of templates to this tab bar, updating it on each emission.
    /// - Returns: AnyCancellable — cancel to stop updates. Store it to keep the binding alive.
    public func bind(templates: some Publisher<[CPTemplate], Never>) -> AnyCancellable {
        let template = base
        return templates
            .receive(on: DispatchQueue.main)
            .sink { [weak template] newTemplates in
                template?.updateTemplates(newTemplates)
            }
    }
}
#endif
