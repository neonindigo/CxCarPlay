#if canImport(CarPlay)
import CarPlay
import Combine

extension CxCarPlayExtension where Base: CPGridTemplate {
    /// Binds a publisher of grid buttons to this template, updating it on each emission.
    /// - Returns: AnyCancellable — cancel to stop updates. Store it to keep the binding alive.
    public func bind(gridButtons: some Publisher<[CPGridButton], Never>) -> AnyCancellable {
        let template = base
        return gridButtons
            .receive(on: DispatchQueue.main)
            .sink { [weak template] buttons in
                template?.updateGridButtons(buttons)
            }
    }
}
#endif
