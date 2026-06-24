import XCTest
import Combine
@testable import CxCarPlay

final class CxCarPlayTests: XCTestCase {
    func testPlaceholder() {
        // Placeholder — real tests in Wave 1
        XCTAssertTrue(true)
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
