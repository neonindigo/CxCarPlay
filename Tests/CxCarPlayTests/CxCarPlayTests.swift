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
    }
}
#endif
