//
//  LabelTableViewCellTest.swift
//  passTests
//
//  The actions in the edit menu of a password's field, which depend on the field's type
//  and on whether its content is revealed.
//

import passKit
import XCTest

@testable import Pass

final class LabelTableViewCellTest: XCTestCase {
    func testPasswordMenu() {
        let cell = makeCell(title: "password", content: "example-password")

        XCTAssertEqual(menuTitles(of: cell), ["Reveal".localize()])
        cell.revealPassword()
        XCTAssertEqual(menuTitles(of: cell), ["Conceal".localize()])
        cell.concealPassword()
        XCTAssertEqual(menuTitles(of: cell), ["Reveal".localize()])
    }

    func testHOTPMenu() {
        let cell = makeCell(title: "HmacBased".localize(), content: "123456")

        XCTAssertEqual(menuTitles(of: cell), ["Reveal".localize(), "NextPassword".localize()])
        cell.revealPassword()
        XCTAssertEqual(menuTitles(of: cell), ["Conceal".localize(), "NextPassword".localize()])
    }

    func testURLMenu() {
        let cell = makeCell(title: "url", content: "https://example.com")

        XCTAssertEqual(menuTitles(of: cell), ["CopyAndOpen".localize()])
    }

    func testOtherMenu() {
        let cell = makeCell(title: "username", content: "example")

        XCTAssertEqual(menuTitles(of: cell), [])
    }

    func testOnlyCopyIsAStandardAction() {
        let cell = makeCell(title: "password", content: "example-password")

        XCTAssertTrue(cell.canPerformAction(#selector(UIResponderStandardEditActions.copy(_:)), withSender: nil))
        XCTAssertFalse(cell.canPerformAction(#selector(UIResponderStandardEditActions.paste(_:)), withSender: nil))
    }

    func testPasswordButton() {
        XCTAssertNotNil(makeCell(title: "password", content: "example-password").accessoryView as? UIButton)
        XCTAssertNil(makeCell(title: "password", content: "").accessoryView)
        XCTAssertEqual(makeCell(title: "HmacBased".localize(), content: "123456").accessoryView?.subviews.count, 2)
    }

    private func makeCell(title: String, content: String) -> LabelTableViewCell {
        let nib = UINib(nibName: "LabelTableViewCell", bundle: Bundle(for: LabelTableViewCell.self))
        let cell = nib.instantiate(withOwner: nil).compactMap { $0 as? LabelTableViewCell }.first!
        cell.cellData = LabelTableViewCellData(title: title, content: content)
        return cell
    }

    // The titles of the actions the cell adds to the system's suggestions.
    private func menuTitles(of cell: LabelTableViewCell) -> [String] {
        let interaction = UIEditMenuInteraction(delegate: cell)
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: .zero)
        let menu = cell.editMenuInteraction(interaction, menuFor: configuration, suggestedActions: [])
        return menu?.children.compactMap { ($0 as? UIAction)?.title } ?? []
    }
}
