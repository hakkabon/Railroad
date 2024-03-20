//
//  Ascii.swift
//  Railroad
//
//  Created by Ulf Akerstedt-Inoue on 2024/03/19.
//

import Foundation

typealias Plotter = (_ x: Int, _ y: Int, _ char: String) -> Void
typealias Coord = (x: Int, y: Int)

struct DiagramElement: Equatable {
    var items: [DiagramElement]?
    var up: Int
    var down: Int
    var height: Int
    var width: Int
    var draw: (_ plotter: Plotter, _ start: Coord) -> Void
    
    static func == (lhs: DiagramElement, rhs: DiagramElement) -> Bool {
        lhs.up == rhs.up &&
        lhs.down == rhs.down &&
        lhs.height == rhs.height &&
        lhs.width == rhs.width
    }
}

func drawLine(_ plotter: Plotter, _ coord: Coord, text: String) {
    text.enumerated().forEach { (index, char) in
        plotter(coord.x + index, coord.y, String(char))
    }
}

func delta(_ coord: Coord, dx xDelta: Int = 0, dy yDelta: Int = 0) -> Coord {
    (x: coord.x + xDelta, y: coord.y + yDelta)
}

let s = (
    h: "─", hu: "┴", hd: "┬", v: "│", vr: "├", vl: "┤", tl: "╭", tr: "╮", bl: "╰", br: "╯",
    right: "→", left: "←"
)

func terminal(name: String) -> DiagramElement {
    DiagramElement(up: 1, down: 1, height: 0, width: name.count + 4) { plotter, start in
        drawLine(plotter, delta(start, dx: 0, dy: -1), text: "╭\(String(repeating: "─", count: name.count + 2))╮")
        drawLine(plotter, start, text: "┤ \(name) ├")
        drawLine(plotter, delta(start, dx: 0, dy: 1), text: "╰\(String(repeating: "─", count: name.count + 2))╯")
    }
}

func nonTerminal(name: String) -> DiagramElement {
    DiagramElement(up: 1, down: 1, height: 0, width: name.count + 4) { plotter, start in
        drawLine(plotter, delta(start, dx: 0, dy: -1), text: "┏\(String(repeating: "━", count: name.count + 2))┓")
        drawLine(plotter, start, text: "┨ \(name) ┠")
        drawLine(plotter, delta(start, dx: 0, dy: 1), text: "┗\(String(repeating: "━", count: name.count + 2))┛")
    }
}

func special(name: String) -> DiagramElement {
    DiagramElement(up: 1, down: 1, height: 0, width: name.count + 4) { plotter, start in
        drawLine(plotter, delta(start, dx: 0, dy: -1), text: "╭\(String(repeating: "┄", count: name.count + 2))╮")
        drawLine(plotter, start, text: "┤ \(name) ├")
        drawLine(plotter, delta(start, dx: 0, dy: 1), text: "╰\(String(repeating: "┄", count: name.count + 2))╯")
    }
}

func comment(comment: String) -> DiagramElement {
    DiagramElement(up: 0, down: 0, height: 0, width: comment.count + 2) { plotter, start in
            drawLine(plotter, start, text: "╴\(comment)╶")
    }
}

func commentWithLine(comment: String) -> DiagramElement {
    DiagramElement(up: 1, down: 0, height: 0, width: comment.count + 2) { plotter, start in
        drawLine(plotter, delta(start, dx: 0, dy: -1), text: " \(comment) ")
        drawLine(plotter, start, text: String(repeating: "─", count: comment.count + 2))
    }
}

func alignWidth(_ plotter: Plotter, _ element: DiagramElement, _ coord: Coord, _ width: Int) {
    let remainingWidth = width - element.width
    let left = Int(floor(Double(remainingWidth) / 2))
    let right = remainingWidth - left
    element.draw(plotter, Coord(x: coord.x + left, y: coord.y))

    for l in 0..<left {
        plotter(coord.x + l, coord.y, s.h)
    }
    for r in 0..<right {
        plotter(coord.x + left + element.width + r, coord.y + element.height, s.h)
    }
}

func group(_ element: DiagramElement, _ label: String = "") -> DiagramElement {
    let width = max(element.width, label.count + 2)
    return DiagramElement(up: element.up + 1, down: element.down + 1, height: element.height, width: width + 2) { plotter, start in
        plotter(start.x, start.y - element.up - 1, s.tl)
        if label.count > 0 {
            comment(comment: label).draw(plotter, delta(start, dx: 1, dy: -1 - element.up))
        }
        drawLine(plotter, delta(start, dx: 1, dy: -1 - element.up), text: String(repeating: "╌", count: width) + "╮")
        for y in 1...element.up {
            plotter(start.x, start.y - y, "╎")
        }
        plotter(start.x, start.y, "┼")
        for y in 1...(element.down + element.height) {
            plotter(start.x, start.y + y, "╎")
        }
        alignWidth(plotter, element, delta(start, dx: 1, dy: 0), width)
        for y in 1...(element.up + element.height) {
            plotter(start.x + width + 1, start.y + element.height - y, "╎")
        }
        plotter(start.x + width + 1, start.y + element.height, "┼")
        for y in 1...element.down {
            plotter(start.x + width + 1, start.y + element.height + y, "╎")
        }
        drawLine(plotter, delta(start, dx: 0, dy: 1 + element.down + element.height), text: "╰" + String(repeating: "╌", count: width) + "╯")
    }
}

// Create a diagram element
func diagram(_ element: DiagramElement, _ complex: Bool = false) -> DiagramElement {
    return DiagramElement(
        up: 0 + element.up,
        down: 0 + element.down + element.height,
        height: element.height,
        width: 2 + element.width
    ) { plotter, start in
        plotter(start.x, start.y, complex ? "╟" : "┠")
        plotter(start.x + element.width + 1, start.y + element.height, complex ? "╢" : "┨")
        element.draw(plotter, delta(start, dx: 1))
    }
}

// Create a sequence of diagram elements
func sequence(_ elements: [DiagramElement]) -> DiagramElement {
    return DiagramElement(
        items: elements,
        up: elements.map({ $0.up }).max() ?? 0,
        down: elements.map({ $0.down }).max() ?? 0,
        height: 0,
        width: elements.reduce(1, { $0 + $1.width + 1 })
    ) { plotter, start in
        plotter(start.x, start.y, s.h)
        var xDelta = 1
        elements.forEach { element in
            element.draw(plotter, delta(start, dx: xDelta))
            xDelta += element.width
            if element.height == 0 {
                plotter(start.x + xDelta, start.y, s.h)
            } else {
                plotter(start.x + xDelta, start.y, s.tl)
                for h in 1..<element.height {
                    plotter(start.x + xDelta, start.y + h, s.v)
                }
                plotter(start.x + xDelta, start.y + element.height, s.br)
            }
            xDelta += 1
        }
    }
}

// Create a skip element
func skip(_ content: String = "") -> DiagramElement {
    return DiagramElement(up: 0, down: 0, height: 0, width: content.count) { plotter, start in
        drawLine(plotter, start, text: content)
    }
}

// A function to create a choice diagram element
func choice(elements: [DiagramElement], defaultChoice: Int = 0) -> DiagramElement {
    // Check if there is only one element in the array
    if elements.count == 1 {
        return elements[0]
    }
    
    // Calculate the up and down values based on the default choice
    let up = elements.enumerated().reduce(0) { (acc, tuple) -> Int in
        let (i, element) = tuple
        if i == defaultChoice {
            return acc + element.up
        } else if i < defaultChoice {
            return acc + element.up + element.down + element.height + 1
        } else {
            return acc
        }
    }
    
    let down = elements.enumerated().reduce(0) { (acc, tuple) -> Int in
        let (i, element) = tuple
        if i == defaultChoice {
            return acc + element.down + element.height
        } else if i > defaultChoice {
            return acc + element.up + element.down + element.height + 1
        } else {
            return acc
        }
    }
    
    // Calculate the width and height of the diagram
    let width = elements.map { $0.width }.max() ?? 0
    let height = elements[defaultChoice].height
    
    // Return the diagram element
    return DiagramElement(items: elements, up: up, down: down - height, height: height, width: width + 2) { plotter, start in
        var yDelta = -up
        for (i, element) in elements.enumerated() {
            if i == 0 {
                plotter(start.x, start.y + yDelta + element.up, yDelta < -element.up ? s.tl : s.hd)
                plotter(start.x + width + 1, start.y + yDelta + element.height + element.up, yDelta < -element.up ? s.tr : s.hd)
            } else if i == elements.count - 1 {
                plotter(start.x, start.y + yDelta + element.up, yDelta > 0 ? s.bl : s.hu)
                plotter(start.x + width + 1, start.y + yDelta + element.height + element.up, yDelta > 0 ? s.br : s.hu)
            } else {
                plotter(start.x, start.y + yDelta + element.up, i == defaultChoice ? "┼" : "├")
                plotter(start.x + width + 1, start.y + yDelta + element.height + element.up, i == defaultChoice ? "┼" : "┤")
            }
            
            if i != elements.count - 1 {
                for y in 1...(element.down + element.height) {
                    plotter(start.x, start.y + element.up + yDelta + y, s.v)
                }
                for y in 1...element.down {
                    plotter(start.x + 1 + width, start.y + element.up + yDelta + y + element.height, s.v)
                }
            }
            if i != 0 {
                for y in 1...element.up {
                    plotter(start.x, start.y + element.up + yDelta - y, s.v)
                }
                for y in 1...(element.up + element.height) {
                    plotter(start.x + 1 + width, start.y + element.up + yDelta - y + element.height, s.v)
                }
            }
            
            alignWidth(plotter, element, delta(start, dx: 1, dy: yDelta + element.up), width)
            yDelta += element.height + element.down + element.up + 1
        }
    }
}

// Define a function to create an optional element
func optional(element: DiagramElement) -> DiagramElement {
    return choice(elements: [skip(s.right), element], defaultChoice: 1)
}

// Define a function to stack multiple elements
func stack(elements: [DiagramElement]) -> DiagramElement {
    let up = elements[0].up
    let down = elements[elements.count - 1].down
    let height = elements.reduce(elements.count) { acc, element in
        if let index = elements.firstIndex(of: element), index > 0 {
            return acc + elements[index - 1].down + element.up + element.height + 1
        } else {
            return acc + element.height + 1
        }
    }

    let width = elements.map { $0.width }.max() ?? 0

    return DiagramElement(items: elements, up: up, down: down, height: height, width: width + 2, draw: { plotter, start in
        plotter(start.x, start.y, s.h)
        var yDelta = -up
        for (i, element) in elements.enumerated() {
            alignWidth(plotter, element, delta(start, dx: 1, dy: yDelta + element.up), width)

            if i < elements.count - 1 {
                alignWidth(plotter, skip(s.left), delta(start, dx: 1, dy: yDelta + element.up + element.height + element.down + 1), width)
                plotter(start.x + width + 1, start.y + element.up + element.height + yDelta, s.tr)
                for y in 1...element.down {
                    plotter(start.x + width + 1, start.y + element.up + element.height + yDelta + y, s.v)
                }
                plotter(start.x + width + 1, start.y + element.up + element.height + yDelta + element.down + 1, s.br)
            }

            if i > 0 {
                plotter(start.x, start.y + yDelta - 1, s.tl)
                for y in 0..<element.up {
                    plotter(start.x, start.y + yDelta + y, s.v)
                }
                plotter(start.x, start.y + yDelta + element.up, s.bl)
            }

            yDelta += element.up + element.height + 2 + element.down
        }
        plotter(start.x + width + 1, start.y + height, s.h)
    })
}

// Repeater function
func repeater(_ repeat: DiagramElement, _ inBetween: DiagramElement = skip()) -> DiagramElement {
    return choice(elements: [`repeat`, sequence([inBetween, skip(s.left)])])
}

// Horizontal choice function
func horizontalChoice(_ elements: [DiagramElement]) -> DiagramElement {
    if elements.count == 1 {
        return elements[0]
    }
    
    let up = elements.reduce(-Int.max) { acc, element in
        max(acc, element.up)
    }
    
    let down = elements.reduce(-Int.max) { acc, element in
        max(acc, element.down + element.height)
    }
    
    let width = elements.reduce(0) { acc, element in
        acc + element.width + 2
    }
    
    return DiagramElement(
        items: elements,
        up: up,
        down: down,
        height: 0,
        width: width
    ) { plotter, start in
        plotter(start.x, start.y, s.hu)
        var xDelta: Int = 1
        for (i, element) in elements.enumerated() {
            for y in 1...Int(up) {
                plotter(start.x + xDelta - 1, start.y - y, s.v)
            }
            if i == 0 {
                plotter(start.x + xDelta - 1, start.y - up - 1, s.tl)
                drawLine(plotter, delta(start, dx: xDelta, dy: -up - 1), text: String(repeating: s.h, count: element.width + 1))
            } else if i == elements.count - 1 {
                plotter(start.x + xDelta - 1, start.y - up - 1, s.tr)
                drawLine(plotter, delta(start, dx: xDelta - 1, dy: down + 1), text: String(repeating: s.h, count: element.width + 1))
            } else {
                plotter(start.x + xDelta - 1, start.y - up - 1, s.hd)
                drawLine(plotter, delta(start, dx: xDelta, dy: -up - 1), text: String(repeating: s.h, count: element.width + 1))
                drawLine(plotter, delta(start, dx: xDelta - 1, dy: down + 1), text: String(repeating: s.h, count: element.width + 1))
            }
            
            element.draw(plotter, delta(start, dx: xDelta))
            xDelta += element.width
            
            for y in 1...Int(down - element.height) {
                plotter(start.x + xDelta, start.y + y + element.height, s.v)
            }
            if i == 0 {
                plotter(start.x + xDelta, start.y + down + 1, s.bl)
            } else if i == elements.count - 1 {
                plotter(start.x + xDelta, start.y + down + 1, s.br)
            } else {
                plotter(start.x + xDelta, start.y + down + 1, s.hu)
            }
            
            if i < elements.count - 1 {
                plotter(start.x + xDelta, start.y + element.height, s.tr)
                plotter(start.x + xDelta + 1, start.y, s.bl)
            } else {
                plotter(start.x + xDelta, start.y, s.hd)
            }
            xDelta += 2
        }
    }
}

// Draw function
func draw(_ element: DiagramElement) -> String {
    typealias Point = (x: Int, y: Int, char: String)
    
    // Determine width and height
    var points: [Point] = []
    let plotter: Plotter = { x, y, char in
        points.append((x, y, char))
    }
    
    element.draw(plotter, (x: 0, y: 0))
    
    let minX = points.reduce(Int.max, { min($0, $1.x) })
    let minY = points.reduce(Int.max, { min($0, $1.y) })

    let maxX = points.reduce(-Int.max, { max($0, $1.x) })
    let maxY = points.reduce(-Int.max, { max($0, $1.y) })

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
