import XCTest
import Combine
@testable import CxCarPlay

#if canImport(CarPlay)
import CarPlay
import Combine

final class CPListTemplateTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    override func tearDown() { cancellables.removeAll(); super.tearDown() }

    /// Pumps the main run-loop until all currently-enqueued main-queue work has run.
    private func flushMain() {
        let exp = expectation(description: "main queue flush")
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1)
    }

    // 1. bind(sections:) calls updateSections on emission
    func testBindUpdatesSections() {
        let template = CPListTemplate(title: "Test", sections: [])
        let subject = PassthroughSubject<[CPListSection], Never>()
        let item = CPListItem(text: "Hello", detailText: nil)
        let section = CPListSection(items: [item])

        template.cx.bind(sections: subject).store(in: &cancellables)
        subject.send([section])
        flushMain()
        XCTAssertEqual(template.sections.count, 1)
    }

    // 2. itemSelected emits when item handler fires
    func testItemSelectedEmitsOnHandlerFire() {
        let template = CPListTemplate(title: "Test", sections: [])
        let subject = PassthroughSubject<[CPListSection], Never>()
        var selections: [Selection] = []
        let selectionExp = expectation(description: "selection received")

        template.cx.itemSelected
            .sink { selection in
                selections.append(selection)
                selection.complete()
                selectionExp.fulfill()
            }
            .store(in: &cancellables)

        let item = CPListItem(text: "Item 1", detailText: nil)
        let section = CPListSection(items: [item])
        template.cx.bind(sections: subject).store(in: &cancellables)
        subject.send([section])
        flushMain()

        // Trigger the injected handler on the first item in the updated section
        let updatedItem = template.sections.first?.items.first as? CPListItem
        updatedItem?.handler?(updatedItem!, {})

        waitForExpectations(timeout: 1)
        XCTAssertEqual(selections.count, 1)
        XCTAssertEqual(selections.first?.item.text, "Item 1")
    }

    // 3. Selection.complete() is idempotent (no double-call crash)
    func testSelectionCompleteIsIdempotent() {
        var handlerCallCount = 0
        let item = CPListItem(text: "X", detailText: nil)
        let selection = Selection(item: item, completionHandler: { handlerCallCount += 1 })
        selection.complete()
        selection.complete()  // second call must be a no-op
        XCTAssertEqual(handlerCallCount, 1)
    }

    // 4. Cancelling bind stops section updates
    func testCancellingBindStopsUpdates() {
        let template = CPListTemplate(title: "Test", sections: [])
        let subject = PassthroughSubject<[CPListSection], Never>()
        var cancellable: AnyCancellable? = template.cx.bind(sections: subject)

        subject.send([CPListSection(items: [CPListItem(text: "A", detailText: nil)])])
        flushMain()
        XCTAssertEqual(template.sections.count, 1)

        cancellable = nil  // cancel
        subject.send([CPListSection(items: [CPListItem(text: "B", detailText: nil), CPListItem(text: "C", detailText: nil)])])
        // sections count should remain 1 after cancellation
        XCTAssertEqual(template.sections.count, 1)
    }
}

#if canImport(CarPlay)
import CarPlay

final class CPTabBarTemplateTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    override func tearDown() { cancellables.removeAll(); super.tearDown() }

    func testBindUpdatesTemplates() {
        let list = CPListTemplate(title: "Tab 1", sections: [])
        let tabBar = CPTabBarTemplate(templates: [list])
        let subject = PassthroughSubject<[CPTemplate], Never>()

        subject.bind(to: tabBar.cx.bind(templates:)).store(in: &cancellables)
        let list2 = CPListTemplate(title: "Tab 2", sections: [])
        subject.send([list, list2])
        XCTAssertEqual(tabBar.templates.count, 2)
    }

    func testCancelStopsUpdates() {
        let list1 = CPListTemplate(title: "A", sections: [])
        let tabBar = CPTabBarTemplate(templates: [list1])
        let subject = PassthroughSubject<[CPTemplate], Never>()
        var cancellable: AnyCancellable? = subject.bind(to: tabBar.cx.bind(templates:))
        let list2 = CPListTemplate(title: "B", sections: [])
        subject.send([list1, list2])
        XCTAssertEqual(tabBar.templates.count, 2)
        cancellable = nil
        let list3 = CPListTemplate(title: "C", sections: [])
        subject.send([list3])
        XCTAssertEqual(tabBar.templates.count, 2)
import UIKit

final class CPGridTemplateTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    override func tearDown() { cancellables.removeAll(); super.tearDown() }

    // 1. bind(gridButtons:) calls updateGridButtons on emission
    func testBindUpdatesButtons() {
        let button1 = CPGridButton(titleVariants: ["Play"], image: UIImage()) { _ in }
        let template = CPGridTemplate(title: "Test", gridButtons: [button1])
        let subject = PassthroughSubject<[CPGridButton], Never>()

        template.cx.bind(gridButtons: subject).store(in: &cancellables)
        let button2 = CPGridButton(titleVariants: ["Pause"], image: UIImage()) { _ in }
        subject.send([button2])
        XCTAssertEqual(template.gridButtons.count, 1)
    }

    // 2. Cancelling stops updates
    func testCancelStopsUpdates() {
        let template = CPGridTemplate(title: "Test", gridButtons: [])
        let subject = PassthroughSubject<[CPGridButton], Never>()
        var cancellable: AnyCancellable? = template.cx.bind(gridButtons: subject)
        let b1 = CPGridButton(titleVariants: ["A"], image: UIImage()) { _ in }
        subject.send([b1])
        XCTAssertEqual(template.gridButtons.count, 1)
        cancellable = nil
        let b2 = CPGridButton(titleVariants: ["B"], image: UIImage()) { _ in }
        let b3 = CPGridButton(titleVariants: ["C"], image: UIImage()) { _ in }
        subject.send([b2, b3])
        XCTAssertEqual(template.gridButtons.count, 1)  // unchanged after cancel
    }
}
#endif
#endif

// Always-compiled placeholder to keep test target non-empty on macOS
final class CxCarPlayPlaceholderTests: XCTestCase {
    func testAlwaysPasses() { XCTAssertTrue(true) }
}
