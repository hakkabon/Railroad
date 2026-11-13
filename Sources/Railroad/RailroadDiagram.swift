//
//  RailroadDiagram.swift
//  Railroad
//
//  Created by Ulf Akerstedt-Inoue on 2024/03/19.
//  Copyright © 2024 hakkabon software. All rights reserved.
//

import Foundation
import CoreGraphics

// MARK: - Regular Expressions & Graphic Diagramming API

/// For literal text strings inside the regexp.
public func literal(_ text: String) -> Box {
    return Box(text: text, style: terminalStyle)
}

/// For character classes like \s, \w, [a-z], etc.
public func characterClass(_ text: String) -> Box {
    return Box(text: text, style: nonTerminalStyle)
}

/// Concatenation of two or more elements.
public func sequence(_ elements: DiagramConvertible...) -> Series {
    return Series(elements: elements.map { $0.toGraphic() })
}

/// Alternation (| in regex).
public func choice(_ elements: DiagramConvertible...) -> Parallel {
    return Parallel(elements: elements.map { $0.toGraphic() })
}

/// Alternation with a designated center line element.
public func choice(_ centerIndex: Int, _ elements: DiagramConvertible...) -> Parallel {
    let p = Parallel(elements: elements.map { $0.toGraphic() })
    p.indexOfCenterElement = centerIndex
    return p
}

public func choice(_ elements: [DiagramConvertible], centerIndex: Int = 0) -> Parallel {
    let p = Parallel(elements: elements.map { $0.toGraphic() })
    p.indexOfCenterElement = centerIndex
    return p
}

/// Empty track bypass.
public func skip() -> Skip {
    return Skip()
}

/// Optional element (? in regex).
/// The drawSkipBelow parameter determines whether the skip line is drawn above or below.
public func optional(_ element: Element) -> Parallel {
    return optional(element, false)
}

public func optional(_ element: DiagramConvertible, _ drawSkipBelow: Bool) -> Parallel {
    let p = Parallel()
    if drawSkipBelow {
        p.add(element.toGraphic())
        p.add(Skip())
    } else {
        p.add(Skip())
        p.add(element.toGraphic())
        p.indexOfCenterElement = 1
    }
    return p
}

/// One or more repetitions (+ in regex).
public func oneOrMore(_ element: DiagramConvertible, _ loop: DiagramConvertible = skip()) -> Loop {
    return Loop(forward: element.toGraphic(), backward: loop.toGraphic())
}

/// Zero or more repetitions (* in regex).
public func zeroOrMore(_ element: DiagramConvertible, _ loop: DiagramConvertible = skip(), _ drawSkipBelow: Bool = false) -> Parallel {
    return optional(oneOrMore(element, loop), drawSkipBelow)
}

/// A capture group in the regex (or labelled decoration frame).
public func capture(_ element: DiagramConvertible, _ text: String = "") -> Decoration {
    return Decoration(element: element.toGraphic(), text: text, style: captureStyle)
}

// MARK: - DSL Aliases

/// each(a, b, c) produces (A -> B -> C)
public func each(_ elements: DiagramConvertible...) -> Series {
    return Series(elements: elements.map { $0.toGraphic() })
}

/// Like | in regex / EBNF (choose 1 of)
public func or(_ elements: DiagramConvertible...) -> Parallel {
    return Parallel(elements: elements.map { $0.toGraphic() })
}

/// Like ? in regex / EBNF (0 or 1 occurrences)
public func maybe(_ element: DiagramConvertible) -> Parallel {
    return optional(element, false)
}

/// Like + in regex / EBNF (1 or more repetitions)
public func many(_ element: DiagramConvertible, _ loop: DiagramConvertible = skip()) -> Loop {
    return oneOrMore(element, loop)
}

/// Like * in regex / EBNF (0 or more repetitions)
public func any(_ element: DiagramConvertible, _ loop: DiagramConvertible = skip()) -> Parallel {
    return zeroOrMore(element, loop, false)
}
