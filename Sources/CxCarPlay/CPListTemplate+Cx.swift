#if canImport(CarPlay)
import CarPlay
import Combine
import ObjectiveC

private var itemSelectedSubjectKey: UInt8 = 0

extension CxCarPlayExtension where Base: CPListTemplate {

    private var itemSelectedSubject: PassthroughSubject<Selection, Never> {
        if let existing = objc_getAssociatedObject(base, &itemSelectedSubjectKey)
            as? PassthroughSubject<Selection, Never> {
            return existing
        }
        let subject = PassthroughSubject<Selection, Never>()
        objc_setAssociatedObject(base, &itemSelectedSubjectKey, subject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return subject
    }

    /// Binds a publisher of sections to this template, updating it on each emission.
    /// Injects selection handlers into each CPListItem so taps publish to `itemSelected`.
    /// - Returns: AnyCancellable — cancel to stop updates. Store it to keep the binding alive.
    public func bind(sections: some Publisher<[CPListSection], Never>) -> AnyCancellable {
        let subject = itemSelectedSubject
        let template = base
        return sections
            .receive(on: DispatchQueue.main)
            .sink { [weak template] newSections in
                guard let template else { return }
                let injected = newSections.map { section in
                    let items = section.items
                        .compactMap { $0 as? CPListItem }
                        .map { item -> CPListItem in
                            let copy = CPListItem(text: item.text, detailText: item.detailText, image: item.image)
                            copy.accessoryType = item.accessoryType
                            copy.accessoryImage = item.accessoryImage
                            copy.isEnabled = item.isEnabled
                            copy.isPlaying = item.isPlaying
                            copy.playbackProgress = item.playbackProgress
                            copy.playingIndicatorLocation = item.playingIndicatorLocation
                            copy.userInfo = item.userInfo
                            copy.handler = { [weak subject] selectableItem, completionHandler in
                                guard let subject,
                                      let listItem = selectableItem as? CPListItem else {
                                    completionHandler()
                                    return
                                }
                                let selection = Selection(item: listItem, completionHandler: completionHandler)
                                subject.send(selection)
                            }
                            return copy
                        }
                    return CPListSection(items: items, header: section.header, sectionIndexTitle: section.sectionIndexTitle)
                }
                template.updateSections(injected, animated: false)
            }
    }

    /// Emits a Selection each time the user taps a bound list item.
    /// Only emits for items bound via `bind(sections:)`.
    public var itemSelected: AnyPublisher<Selection, Never> {
        itemSelectedSubject.eraseToAnyPublisher()
    }
}
#endif
