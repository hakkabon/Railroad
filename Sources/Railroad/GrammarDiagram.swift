//
//  GrammarDiagram.swift
//  Railroad
//
//  Created by Ulf Akerstedt-Inoue on 2025/12/29.
//  Copyright © 2025 hakkabon software. All rights reserved.
//

import Foundation

// MARK: - Type Definitions

public typealias Plotter = (Int, Int, String) -> Void

public struct Coord {
    public let x: Int
    public let y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public protocol DiagramElement {
    var items: [DiagramElement]? { get }
    var up: Int { get }
    var down: Int { get }
    var height: Int { get }
    var width: Int { get }
    
    func draw(plotter: Plotter, start: Coord)
}

// MARK: - Drawing Function

private struct Point {
    let x: Int
    let y: Int
    let char: String
}

public func draw(_ element: DiagramElement) -> String {
    var points: [Point] = []
    
    let plotter: Plotter = { x, y, char in
        points.append(Point(x: x, y: y, char: char))
    }
    
    element.draw(plotter: plotter, start: Coord(x: 0, y: 0))
    
    let minX = points.map { $0.x }.min() ?? 0
    let minY = points.map { $0.y }.min() ?? 0
    let maxX = points.map { $0.x }.max() ?? 0
    let maxY = points.map { $0.y }.max() ?? 0
    
    let height = maxY - minY
    let width = maxX - minX
    
    var canvas = Array(repeating: Array(repeating: " ", count: width + 1), count: height + 1)
    
    for y in minY...maxY {
        for x in minX...maxX {
            if let point = points.first(where: { $0.x == x && $0.y == y }) {
                canvas[y - minY][x - minX] = point.char
            }
        }
    }
    
    return canvas.map { $0.joined() }.joined(separator: "\n")
}

// MARK: - Factory Functions for BNF Grammars

public func terminal(_ name: String) -> Terminal {
    return Terminal(name)
}

public func terminal(name: String) -> Terminal {
    return Terminal(name)
}

public func nonTerminal(_ name: String) -> NonTerminal {
    return NonTerminal(name)
}

public func nonTerminal(name: String) -> NonTerminal {
    return NonTerminal(name)
}

public func special(_ name: String) -> Special {
    return Special(name)
}

public func special(name: String) -> Special {
    return Special(name)
}

public func comment(_ comment: String) -> Comment {
    return Comment(comment)
}

public func comment(comment: String) -> Comment {
    return Comment(comment)
}

public func commentWithLine(_ comment: String) -> CommentWithLine {
    return CommentWithLine(comment)
}

public func commentWithLine(comment: String) -> CommentWithLine {
    return CommentWithLine(comment)
}

public func group(_ element: DiagramElement, label: String = "") -> Group {
    return Group(element, label: label)
}

public func group(element: DiagramElement, label: String = "") -> Group {
    return Group(element, label: label)
}

public func grammarDiagram(_ element: DiagramElement, complex: Bool = false) -> DiagramElement {
    return AsciiDiagram(element, complex: complex)
}

public func diagram(_ element: DiagramElement, complex: Bool) -> DiagramElement {
    return AsciiDiagram(element, complex: complex)
}

public func sequence(_ elements: [DiagramElement]) -> Sequence {
    return Sequence(elements)
}

public func sequence(elements: [DiagramElement]) -> Sequence {
    return Sequence(elements)
}

public func skip(_ content: String = "") -> AsciiSkip {
    return AsciiSkip(content)
}

public func optional(_ element: DiagramElement) -> Choice {
    return Choice([AsciiSkip(BoxChars.right), element], defaultChoice: 1)
}

public func optional(element: DiagramElement) -> Choice {
    return Choice([AsciiSkip(BoxChars.right), element], defaultChoice: 1)
}

public func choice(_ elements: [DiagramElement], defaultChoice: Int = 0) -> Choice {
    return Choice(elements, defaultChoice: defaultChoice)
}

public func choice(elements: [DiagramElement], defaultChoice: Int = 0) -> Choice {
    return Choice(elements, defaultChoice: defaultChoice)
}

public func repeater(_ repeatElement: DiagramElement, inBetween: DiagramElement = AsciiSkip()) -> Choice {
    return Choice([repeatElement, Sequence([inBetween, AsciiSkip(BoxChars.left)])])
}

public func repeater(_ repeatElement: DiagramElement, _ inBetween: DiagramElement) -> Choice {
    return repeater(repeatElement, inBetween: inBetween)
}

public func stack(_ elements: [DiagramElement]) -> Stack {
    return Stack(elements)
}

public func stack(elements: [DiagramElement]) -> Stack {
    return Stack(elements)
}

public func horizontalChoice(_ elements: [DiagramElement]) -> HorizontalChoice {
    return HorizontalChoice(elements)
}

public func horizontalChoice(elements: [DiagramElement]) -> HorizontalChoice {
    return HorizontalChoice(elements)
}
