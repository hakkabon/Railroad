//
//  AsciiTests.swift
//
//
//  Created by Ulf Akerstedt-Inoue on 2024/03/20.
//

import XCTest
@testable import Railroad

final class AsciiTests: XCTestCase {

    func testChoiceOneElement() throws {
        let diagram = choice(elements: [terminal(name: "a")])
        let output = draw(diagram)
        print(output)
        let expected = [
            "╭───╮",
            "┤ a ├",
            "╰───╯"
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }
    
    func testChoiceThreeElements() throws {
        let diagram = choice(elements: [terminal(name: "a"), terminal(name: "b"), terminal(name: "c")])
        let output = draw(diagram)
        print(output)
        let expected = [
            " ╭───╮ ",
            "┬┤ a ├┬",
            "│╰───╯│",
            "│╭───╮│",
            "├┤ b ├┤",
            "│╰───╯│",
            "│╭───╮│",
            "╰┤ c ├╯",
            " ╰───╯ ",
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }
    
    func testChoiceMiddleDefault() throws {
        let diagram = choice(elements: [terminal(name: "a"), terminal(name: "b"), terminal(name: "c")], defaultChoice: 1)
        let output = draw(diagram)
        print(output)
        let expected = [
            " ╭───╮ ",
            "╭┤ a ├╮",
            "│╰───╯│",
            "│╭───╮│",
            "┼┤ b ├┼",
            "│╰───╯│",
            "│╭───╮│",
            "╰┤ c ├╯",
            " ╰───╯ "
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }
    
    func testChoiceBottomDefault() throws {
        let diagram = choice(elements: [terminal(name: "a"), terminal(name: "b"), terminal(name: "c")], defaultChoice: 2)
        let output = draw(diagram)
        print(output)
        let expected = [
            " ╭───╮ ",
            "╭┤ a ├╮",
            "│╰───╯│",
            "│╭───╮│",
            "├┤ b ├┤",
            "│╰───╯│",
            "│╭───╮│",
            "┴┤ c ├┴",
            " ╰───╯ ",
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }
    
    func testChoiceFourElements() throws {
        let diagram = choice(elements: [terminal(name: "a"), terminal(name: "b"), terminal(name: "c"), terminal(name: "d")])
        let output = draw(diagram)
        print(output)
        let expected = [
            " ╭───╮ ",
            "┬┤ a ├┬",
            "│╰───╯│",
            "│╭───╮│",
            "├┤ b ├┤",
            "│╰───╯│",
            "│╭───╮│",
            "├┤ c ├┤",
            "│╰───╯│",
            "│╭───╮│",
            "╰┤ d ├╯",
            " ╰───╯ ",
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }

    func testChoiceWithHeightDefaultFirst() throws {
        let diagram = choice(
            elements: [terminal(name: "a"), stack(elements: [terminal(name: "b"), terminal(name: "c")]), terminal(name: "d")],
            defaultChoice: 1
        )
        let output = draw(diagram)
        print(output)
        let expected = [
            "  ╭───╮  ",
            "╭─┤ a ├─╮",
            "│ ╰───╯ │",
            "│ ╭───╮ │",
            "┼─┤ b ├╮│",
            "│ ╰───╯││",
            "│╭──←──╯│",
            "││╭───╮ │",
            "│╰┤ c ├─┼",
            "│ ╰───╯ │",
            "│ ╭───╮ │",
            "╰─┤ d ├─╯",
            "  ╰───╯  "
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
        XCTAssertEqual(diagram.height, 4)
        XCTAssertEqual(diagram.up, 4)
        XCTAssertEqual(diagram.down, 4)
    }
    
    func testChoiceWithHeightDefaultTop() throws {
        let diagram = choice(
            elements: [terminal(name: "a"), stack(elements: [terminal(name: "b"), terminal(name: "c")]), terminal(name: "d")],
            defaultChoice: 0
        )
        let output = draw(diagram)
        print(output)
        let expected = [
            "  ╭───╮  ",
            "┬─┤ a ├─┬",
            "│ ╰───╯ │",
            "│ ╭───╮ │",
            "├─┤ b ├╮│",
            "│ ╰───╯││",
            "│╭──←──╯│",
            "││╭───╮ │",
            "│╰┤ c ├─┤",
            "│ ╰───╯ │",
            "│ ╭───╮ │",
            "╰─┤ d ├─╯",
            "  ╰───╯  "
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
        XCTAssertEqual(diagram.height, 0)
        XCTAssertEqual(diagram.up, 1)
        XCTAssertEqual(diagram.down, 11)
    }

    func testChoiceVariableWidth() throws {
        let diagram = choice(elements: [
            terminal(name: "abc"),
            terminal(name: "d"),
            terminal(name: "efgh"),
            terminal(name: "i"),
            terminal(name: "jklmnop"),
        ])
        let output = draw(diagram)
        print(output)
        let expected = [
            "   ╭─────╮   ",
            "┬──┤ abc ├──┬",
            "│  ╰─────╯  │",
            "│   ╭───╮   │",
            "├───┤ d ├───┤",
            "│   ╰───╯   │",
            "│ ╭──────╮  │",
            "├─┤ efgh ├──┤",
            "│ ╰──────╯  │",
            "│   ╭───╮   │",
            "├───┤ i ├───┤",
            "│   ╰───╯   │",
            "│╭─────────╮│",
            "╰┤ jklmnop ├╯",
            " ╰─────────╯ "
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }

    // drawing error!
    func testOptional() throws {
        let diagram = optional(element: terminal(name: "abc"))
        let output = draw(diagram)
        print(output)
        let expected = [
            "╭───→───╮",
            "│╭─────╮│",
            "┴┤ abc ├┴",
            " ╰─────╯ ",
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }

    // drawing error!
    func testOptionalChoice() throws {
        let diagram = optional(element: choice(elements: [terminal(name: "a"), terminal(name: "b"), terminal(name: "c")], defaultChoice: 1))
        let output = draw(diagram)
        print(output)
        let expected = [
            "╭───→───╮",
            "│ ╭───╮ │",
            "│╭┤ a ├╮│",
            "││╰───╯││",
            "││╭───╮││",
            "┴┼┤ b ├┼┴",
            " │╰───╯│ ",
            " │╭───╮│ ",
            " ╰┤ c ├╯ ",
            "  ╰───╯  "
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }

    // drawing error!
    func testRepeatElement() throws {
        let diagram = repeater(terminal(name: "abc"))
        let output = draw(diagram)
        print(output)
        let expected = [
            " ╭─────╮ ",
            "┬┤ abc ├┬",
            "│╰─────╯│",
            "╰───←───╯",
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }

    func testRepeatElementWithItem() throws {
        let diagram = repeater(terminal(name: "abc"), terminal(name: ","))
        let output = draw(diagram)
        print(output)
        let expected = [
            "  ╭─────╮  ",
            "┬─┤ abc ├─┬",
            "│ ╰─────╯ │",
            "│ ╭───╮   │",
            "╰─┤ , ├─←─╯",
            "  ╰───╯    ",
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }
    
    func testSequenceOneElement() throws {
        let diagram = sequence([terminal(name: "a")])
        let output = draw(diagram)
        print(output)
        let expected = [
            " ╭───╮ ",
            "─┤ a ├─",
            " ╰───╯ "
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }
    
    func testSequenceMultipleElements() throws {
        let diagram = sequence([terminal(name: "a"), terminal(name: "b"), terminal(name: "c")])
        let output = draw(diagram)
        print(output)
        let expected = [
            " ╭───╮ ╭───╮ ╭───╮ ",
            "─┤ a ├─┤ b ├─┤ c ├─",
            " ╰───╯ ╰───╯ ╰───╯ "
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }
    
    func testSequenceWithDifferentWidths() throws {
        let diagram = sequence([terminal(name: "a"), terminal(name: "bcdef"), terminal(name: "ghi")])
        let output = draw(diagram)
        print(output)
        let expected = [
            " ╭───╮ ╭───────╮ ╭─────╮ ",
            "─┤ a ├─┤ bcdef ├─┤ ghi ├─",
            " ╰───╯ ╰───────╯ ╰─────╯ "
        ].joined(separator: "\n")
        XCTAssertEqual(output, expected)
    }
}
