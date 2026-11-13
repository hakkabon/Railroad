//
//  Diagram.swift
//  GrammarDiagram
//
//  Created by Ulf Akerstedt-Inoue on 2025/12/29.
//  Copyright © 2025 hakkabon software. All rights reserved.
//

import Foundation

// MARK: - Helper Functions

func drawLine(plotter: Plotter, coord: Coord, text: String) {
    for (i, char) in text.enumerated() {
        plotter(coord.x + i, coord.y, String(char))
    }
}

func delta(_ coord: Coord, xDelta: Int = 0, yDelta: Int = 0) -> Coord {
    return Coord(x: coord.x + xDelta, y: coord.y + yDelta)
}

// MARK: - Box Drawing Characters

struct BoxChars {
    static let h = "─"
    static let hu = "┴"
    static let hd = "┬"
    static let v = "│"
    static let vr = "├"
    static let vl = "┤"
    static let tl = "╭"
    static let tr = "╮"
    static let bl = "╰"
    static let br = "╯"
    static let right = "▶︎"
    static let left = "◀︎"
}

// MARK: - Diagram Element Implementations

struct Terminal: DiagramElement {
    let items: [DiagramElement]? = nil
    let name: String
    let up = 1
    let down = 1
    let height = 0
    var width: Int { name.count + 4 }
    
    init(_ name: String) {
        self.name = name
    }
    
    func draw(plotter: Plotter, start: Coord) {
        let repeatCount = name.count + 2
        drawLine(plotter: plotter, coord: delta(start, yDelta: -1),
                text: "╭\(String(repeating: "─", count: repeatCount))╮")
        drawLine(plotter: plotter, coord: start, text: "┤ \(name) ├")
        drawLine(plotter: plotter, coord: delta(start, yDelta: 1),
                text: "╰\(String(repeating: "─", count: repeatCount))╯")
    }
}

struct NonTerminal: DiagramElement {
    let items: [DiagramElement]? = nil
    let name: String
    let up = 1
    let down = 1
    let height = 0
    var width: Int { name.count + 4 }
    
    init(_ name: String) {
        self.name = name
    }
    
    func draw(plotter: Plotter, start: Coord) {
        let repeatCount = name.count + 2
        drawLine(plotter: plotter, coord: delta(start, yDelta: -1),
                text: "┏\(String(repeating: "━", count: repeatCount))┓")
        drawLine(plotter: plotter, coord: start, text: "┨ \(name) ┠")
        drawLine(plotter: plotter, coord: delta(start, yDelta: 1),
                text: "┗\(String(repeating: "━", count: repeatCount))┛")
    }
}

struct Special: DiagramElement {
    let items: [DiagramElement]? = nil
    let name: String
    let up = 1
    let down = 1
    let height = 0
    var width: Int { name.count + 4 }
    
    init(_ name: String) {
        self.name = name
    }
    
    func draw(plotter: Plotter, start: Coord) {
        let repeatCount = name.count + 2
        drawLine(plotter: plotter, coord: delta(start, yDelta: -1),
                text: "╭\(String(repeating: "┄", count: repeatCount))╮")
        drawLine(plotter: plotter, coord: start, text: "┤ \(name) ├")
        drawLine(plotter: plotter, coord: delta(start, yDelta: 1),
                text: "╰\(String(repeating: "┄", count: repeatCount))╯")
    }
}

struct Comment: DiagramElement {
    let items: [DiagramElement]? = nil
    let comment: String
    let up = 0
    let down = 0
    let height = 0
    var width: Int { comment.count + 2 }
    
    init(_ comment: String) {
        self.comment = comment
    }
    
    func draw(plotter: Plotter, start: Coord) {
        drawLine(plotter: plotter, coord: start, text: "╴\(comment)╶")
    }
}

struct CommentWithLine: DiagramElement {
    let items: [DiagramElement]? = nil
    let comment: String
    let up = 1
    let down = 0
    let height = 0
    var width: Int { comment.count + 2 }
    
    init(_ comment: String) {
        self.comment = comment
    }
    
    func draw(plotter: Plotter, start: Coord) {
        drawLine(plotter: plotter, coord: delta(start, yDelta: -1), text: " \(comment) ")
        drawLine(plotter: plotter, coord: start, text: String(repeating: "─", count: comment.count + 2))
    }
}

func alignWidth(plotter: Plotter, element: DiagramElement, coord: Coord, width: Int) {
    let remainingWidth = width - element.width
    let left = remainingWidth / 2
    let right = remainingWidth - left
    
    element.draw(plotter: plotter, start: Coord(x: coord.x + left, y: coord.y))
    
    for l in 0..<left {
        plotter(coord.x + l, coord.y, BoxChars.h)
    }
    for r in 0..<right {
        plotter(coord.x + left + element.width + r, coord.y + element.height, BoxChars.h)
    }
}

struct Group: DiagramElement {
    let items: [DiagramElement]? = nil
    let element: DiagramElement
    let label: String
    let up: Int
    let down: Int
    let height: Int
    let width: Int
    
    init(_ element: DiagramElement, label: String = "") {
        self.element = element
        self.label = label
        let labelWidth = label.isEmpty ? 0 : label.count + 2
        let computedWidth = max(element.width, labelWidth)
        
        self.up = element.up + 1
        self.down = element.down + 1
        self.height = element.height
        self.width = computedWidth + 2
    }
    
    func draw(plotter: Plotter, start: Coord) {
        let computedWidth = width - 2
        
        plotter(start.x, start.y - element.up - 1, BoxChars.tl)
        
        if !label.isEmpty {
            Comment(label).draw(plotter: plotter, start: delta(start, xDelta: 1, yDelta: -1 - element.up))
        }
        
        drawLine(plotter: plotter, coord: delta(start, xDelta: 1, yDelta: -1 - element.up),
                text: "\(String(repeating: "╌", count: computedWidth))╮")
        
        for y in 1...element.up {
            plotter(start.x, start.y - y, "╎")
        }
        
        plotter(start.x, start.y, "┼")
        
        for y in 1...(element.down + element.height) {
            plotter(start.x, start.y + y, "╎")
        }
        
        alignWidth(plotter: plotter, element: element, coord: delta(start, xDelta: 1), width: computedWidth)
        
        for y in 1...(element.up + element.height) {
            plotter(start.x + computedWidth + 1, start.y + element.height - y, "╎")
        }
        
        plotter(start.x + computedWidth + 1, start.y + element.height, "┼")
        
        for y in 1...element.down {
            plotter(start.x + computedWidth + 1, start.y + element.height + y, "╎")
        }
        
        drawLine(plotter: plotter, coord: delta(start, yDelta: 1 + element.down + element.height),
                text: "╰\(String(repeating: "╌", count: computedWidth))╯")
    }
}

struct Diagram: DiagramElement {
    let items: [DiagramElement]? = nil
    let element: DiagramElement
    let complex: Bool
    let up: Int
    let down: Int
    let height: Int
    let width: Int
    
    init(_ element: DiagramElement, complex: Bool = false) {
        self.element = element
        self.complex = complex
        self.up = element.up
        self.down = element.down + element.height
        self.height = element.height
        self.width = 2 + element.width
    }
    
    func draw(plotter: Plotter, start: Coord) {
        plotter(start.x, start.y, complex ? "╟" : "┠")
        plotter(start.x + element.width + 1, start.y + element.height, complex ? "╢" : "┨")
        element.draw(plotter: plotter, start: delta(start, xDelta: 1))
    }
}

struct Sequence: DiagramElement {
    let items: [DiagramElement]?
    let elements: [DiagramElement]
    let up: Int
    let down: Int
    let height = 0
    let width: Int
    
    init(_ elements: [DiagramElement]) {
        self.elements = elements
        self.items = elements
        self.up = elements.map { $0.up }.max() ?? 0
        self.down = elements.map { $0.down }.max() ?? 0
        self.width = elements.reduce(1) { acc, element in acc + element.width + 1 }
    }
    
    func draw(plotter: Plotter, start: Coord) {
        plotter(start.x, start.y, BoxChars.h)
        var xDelta = 1
        
        for element in elements {
            element.draw(plotter: plotter, start: delta(start, xDelta: xDelta))
            xDelta += element.width
            
            if element.height == 0 {
                plotter(start.x + xDelta, start.y, BoxChars.h)
            } else {
                plotter(start.x + xDelta, start.y, BoxChars.tl)
                for h in 1..<element.height {
                    plotter(start.x + xDelta, start.y + h, BoxChars.v)
                }
                plotter(start.x + xDelta, start.y + element.height, BoxChars.br)
            }
            xDelta += 1
        }
    }
}

struct Choice: DiagramElement {
    let items: [DiagramElement]?
    let elements: [DiagramElement]
    let defaultChoice: Int
    let up: Int
    let down: Int
    let height: Int
    let width: Int
    
    init(_ elements: [DiagramElement], defaultChoice: Int = 0) {
        self.elements = elements
        self.items = elements
        self.defaultChoice = defaultChoice
        
        if elements.count == 1 {
            let element = elements[0]
            self.up = element.up
            self.down = element.down
            self.height = element.height
            self.width = element.width
            return
        }
        
        let computedUp = elements.enumerated().reduce(0) { acc, item in
            let (i, element) = item
            if i == defaultChoice {
                return acc + element.up
            } else if i < defaultChoice {
                return acc + element.up + element.down + element.height + 1
            } else {
                return acc
            }
        }
        
        let computedDown = elements.enumerated().reduce(0) { acc, item in
            let (i, element) = item
            if i == defaultChoice {
                return acc + element.down + element.height
            } else if i > defaultChoice {
                return acc + element.up + element.down + element.height + 1
            } else {
                return acc
            }
        }
        
        let computedWidth = elements.map { $0.width }.max() ?? 0
        let computedHeight = elements[defaultChoice].height
        
        self.up = computedUp
        self.down = computedDown - computedHeight
        self.height = computedHeight
        self.width = computedWidth + 2
    }
    
    func draw(plotter: Plotter, start: Coord) {
        if elements.count == 1 {
            elements[0].draw(plotter: plotter, start: start)
            return
        }
        
        let computedWidth = width - 2
        var yDelta = -up
        
        for (i, element) in elements.enumerated() {
            if i == 0 {
                plotter(start.x, start.y + yDelta + element.up,
                       yDelta < -element.up ? BoxChars.tl : BoxChars.hd)
                plotter(start.x + computedWidth + 1, start.y + yDelta + element.height + element.up,
                       yDelta < -element.up ? BoxChars.tr : BoxChars.hd)
            } else if i == elements.count - 1 {
                plotter(start.x, start.y + yDelta + element.up,
                       yDelta > 0 ? BoxChars.bl : BoxChars.hu)
                plotter(start.x + computedWidth + 1, start.y + yDelta + element.height + element.up,
                       yDelta > 0 ? BoxChars.br : BoxChars.hu)
            } else {
                plotter(start.x, start.y + yDelta + element.up,
                       i == defaultChoice ? "┼" : "├")
                plotter(start.x + computedWidth + 1, start.y + yDelta + element.height + element.up,
                       i == defaultChoice ? "┼" : "┤")
            }
            
            if i != elements.count - 1 && element.down >= 1 {
                for y in 1...(element.down + element.height) {
                    plotter(start.x, start.y + element.up + yDelta + y, BoxChars.v)
                }
                for y in 1...element.down {
                    plotter(start.x + 1 + computedWidth, start.y + element.up + yDelta + y + element.height, BoxChars.v)
                }
            }
            
            if i != 0  && element.up >= 1 {
                for y in 1...element.up {
                    plotter(start.x, start.y + element.up + yDelta - y, BoxChars.v)
                }
                for y in 1...(element.up + element.height) {
                    plotter(start.x + 1 + computedWidth, start.y + element.up + yDelta - y + element.height, BoxChars.v)
                }
            }
            
            alignWidth(plotter: plotter, element: element,
                      coord: delta(start, xDelta: 1, yDelta: yDelta + element.up), width: computedWidth)
            
            yDelta += element.height + element.down + element.up + 1
        }
    }
}

struct Stack: DiagramElement {
    let items: [DiagramElement]?
    let elements: [DiagramElement]
    let up: Int
    let down: Int
    let height: Int
    let width: Int
    
    init(_ elements: [DiagramElement]) {
        self.elements = elements
        self.items = elements
        self.up = elements.first?.up ?? 0
        self.down = elements.last?.down ?? 0
        
        let computedHeight = elements.enumerated().reduce(elements.count - 2) { acc, item in
            let (i, element) = item
            if i == 0 {
                return acc + element.height + 1
            } else {
                let prevElement = elements[i - 1]
                return acc + prevElement.down + element.up + element.height + 1
            }
        }
        
        let computedWidth = elements.map { $0.width }.max() ?? 0
        
        self.height = computedHeight
        self.width = computedWidth + 2
    }
    
    func draw(plotter: Plotter, start: Coord) {
        let computedWidth = width - 2
        plotter(start.x, start.y, BoxChars.h)
        var yDelta = -up
        
        for (i, element) in elements.enumerated() {
            alignWidth(plotter: plotter, element: element,
                      coord: delta(start, xDelta: 1, yDelta: yDelta + element.up), width: computedWidth)
            
            if i < elements.count - 1 {
                alignWidth(plotter: plotter, element: Skip(BoxChars.left),
                          coord: delta(start, xDelta: 1, yDelta: yDelta + element.up + element.height + element.down + 1),
                          width: computedWidth)
                plotter(start.x + computedWidth + 1, start.y + element.up + element.height + yDelta, BoxChars.tr)
                
                for y in 1...element.down {
                    plotter(start.x + computedWidth + 1, start.y + element.up + element.height + yDelta + y, BoxChars.v)
                }
                
                plotter(start.x + computedWidth + 1, start.y + element.up + element.height + yDelta + element.down + 1, BoxChars.br)
            }
            
            if i > 0 {
                plotter(start.x, start.y + yDelta - 1, BoxChars.tl)
                for y in 0..<element.up {
                    plotter(start.x, start.y + yDelta + y, BoxChars.v)
                }
                plotter(start.x, start.y + yDelta + element.up, BoxChars.bl)
            }
            
            yDelta += element.up + element.height + 2 + element.down
        }
        
        plotter(start.x + computedWidth + 1, start.y + height, BoxChars.h)
    }
}

struct HorizontalChoice: DiagramElement {
    let items: [DiagramElement]?
    let elements: [DiagramElement]
    let up: Int
    let down: Int
    let height = 0
    let width: Int
    
    init(_ elements: [DiagramElement]) {
        self.elements = elements
        self.items = elements
        
        if elements.count == 1 {
            let element = elements[0]
            self.up = element.up
            self.down = element.down
            self.width = element.width
            return
        }
        
        self.up = elements.map { $0.up }.max() ?? 0
        self.down = elements.map { $0.down + $0.height }.max() ?? 0
        self.width = elements.reduce(0) { acc, element in acc + element.width + 2 }
    }
    
    func draw(plotter: Plotter, start: Coord) {
        if elements.count == 1 {
            elements[0].draw(plotter: plotter, start: start)
            return
        }
        
        plotter(start.x, start.y, BoxChars.hu)
        var xDelta = 1
        
        for (i, element) in elements.enumerated() {
            for y in 1...up {
                plotter(start.x + xDelta - 1, start.y - y, BoxChars.v)
            }
            
            if i == 0 {
                plotter(start.x + xDelta - 1, start.y - up - 1, BoxChars.tl)
                drawLine(plotter: plotter, coord: delta(start, xDelta: xDelta, yDelta: -up - 1),
                        text: String(repeating: BoxChars.h, count: element.width + 1))
            } else if i == elements.count - 1 {
                plotter(start.x + xDelta - 1, start.y - up - 1, BoxChars.tr)
                drawLine(plotter: plotter, coord: delta(start, xDelta: xDelta - 1, yDelta: down + 1),
                        text: String(repeating: BoxChars.h, count: element.width + 1))
            } else {
                plotter(start.x + xDelta - 1, start.y - up - 1, BoxChars.hd)
                drawLine(plotter: plotter, coord: delta(start, xDelta: xDelta, yDelta: -up - 1),
                        text: String(repeating: BoxChars.h, count: element.width + 1))
                drawLine(plotter: plotter, coord: delta(start, xDelta: xDelta - 1, yDelta: down + 1),
                        text: String(repeating: BoxChars.h, count: element.width + 1))
            }
            
            element.draw(plotter: plotter, start: delta(start, xDelta: xDelta))
            xDelta += element.width
            
            for y in 1...(down - element.height) {
                plotter(start.x + xDelta, start.y + y + element.height, BoxChars.v)
            }
            
            if i == 0 {
                plotter(start.x + xDelta, start.y + down + 1, BoxChars.bl)
            } else if i == elements.count - 1 {
                plotter(start.x + xDelta, start.y + down + 1, BoxChars.br)
            } else {
                plotter(start.x + xDelta, start.y + down + 1, BoxChars.hu)
            }
            
            if i < elements.count - 1 {
                plotter(start.x + xDelta, start.y + element.height, BoxChars.tr)
                plotter(start.x + xDelta + 1, start.y, BoxChars.bl)
            } else {
                plotter(start.x + xDelta, start.y, BoxChars.hd)
            }
            
            xDelta += 2
        }
    }
}
