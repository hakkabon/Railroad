//
//  Diagram.swift
//  GrammarDiagram
//
//  Created by Ulf Akerstedt-Inoue on 2025/12/29.
//  Copyright © 2025 hakkabon software. All rights reserved.
//

import Foundation

// MARK: - Type Definitions

public typealias Plotter = (Int, Int, String) -> Void

public struct Coord {
    let x: Int
    let y: Int
}

public protocol DiagramElement {
    var items: [DiagramElement]? { get }
    var up: Int { get }
    var down: Int { get }
    var height: Int { get }
    var width: Int { get }
    
    func draw(plotter: Plotter, start: Coord)
}

public struct Skip: DiagramElement {
    public let items: [DiagramElement]? = nil
    let content: String
    public let up = 0
    public let down = 0
    public let height = 0
    public var width: Int { content.count }
    
    public init(_ content: String = "") {
        self.content = content
    }
    
    public func draw(plotter: Plotter, start: Coord) {
        drawLine(plotter: plotter, coord: start, text: content)
    }
}

// MARK: - Drawing Function

fileprivate struct Point {
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

// MARK: - Factory Functions

public func terminal(_ name: String) -> DiagramElement {
    return Terminal(name)
}

public func nonTerminal(_ name: String) -> DiagramElement {
    return NonTerminal(name)
}

public func special(_ name: String) -> DiagramElement {
    return Special(name)
}

public func comment(_ comment: String) -> DiagramElement {
    return Comment(comment)
}

public func commentWithLine(_ comment: String) -> DiagramElement {
    return CommentWithLine(comment)
}

public func group(_ element: DiagramElement, label: String = "") -> DiagramElement {
    return Group(element, label: label)
}

public func diagram(_ element: DiagramElement, complex: Bool = false) -> DiagramElement {
    return Diagram(element, complex: complex)
}

public func sequence(_ elements: [DiagramElement]) -> DiagramElement {
    return Sequence(elements)
}

public func skip(_ content: String = "") -> DiagramElement {
    return Skip(content)
}

public func optional(_ element: DiagramElement) -> DiagramElement {
    return Choice([Skip(BoxChars.right), element], defaultChoice: 1)
}

public func choice(_ elements: [DiagramElement], defaultChoice: Int = 0) -> DiagramElement {
    return Choice(elements, defaultChoice: defaultChoice)
}

public func repeater(_ repeatElement: DiagramElement, inBetween: DiagramElement = Skip()) -> DiagramElement {
    return Choice([repeatElement, Sequence([inBetween, Skip(BoxChars.left)])])
}

public func stack(_ elements: [DiagramElement]) -> DiagramElement {
    return Stack(elements)
}

public func horizontalChoice(_ elements: [DiagramElement]) -> DiagramElement {
    return HorizontalChoice(elements)
}
