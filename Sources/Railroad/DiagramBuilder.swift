//
//  DiagramBuilder.swift
//  Railroad
//
//  Created by Ulf Akerstedt-Inoue on 2026/11/13.
//  Copyright © 2026 hakkabon software. All rights reserved.
//

import Foundation

// MARK: - Result Builder for Railroad Diagrams

@resultBuilder
public struct DiagramBuilder {
    public static func buildBlock(_ components: DiagramConvertible...) -> [DiagramConvertible] {
        return components
    }
    
    public static func buildBlock(_ components: [DiagramConvertible]...) -> [DiagramConvertible] {
        return components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: [DiagramConvertible]?) -> [DiagramConvertible] {
        return component ?? []
    }
    
    public static func buildEither(first component: [DiagramConvertible]) -> [DiagramConvertible] {
        return component
    }
    
    public static func buildEither(second component: [DiagramConvertible]) -> [DiagramConvertible] {
        return component
    }
    
    public static func buildArray(_ components: [[DiagramConvertible]]) -> [DiagramConvertible] {
        return components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: DiagramConvertible) -> [DiagramConvertible] {
        return [expression]
    }
    
    public static func buildExpression(_ expression: [DiagramConvertible]) -> [DiagramConvertible] {
        return expression
    }
}

// MARK: - Function Builder Overloads for Functional API

/// Concatenates elements built in the trailing closure into a Series.
public func sequence(@DiagramBuilder _ content: () -> [DiagramConvertible]) -> Series {
    let elements = content()
    return Series(elements: elements.map { $0.toGraphic() })
}

/// Chooses from alternatives built in the trailing closure (Parallel).
public func choice(@DiagramBuilder _ content: () -> [DiagramConvertible]) -> Parallel {
    let elements = content()
    return Parallel(elements: elements.map { $0.toGraphic() })
}

/// Chooses from alternatives with a designated center element index.
public func choice(_ centerIndex: Int, @DiagramBuilder _ content: () -> [DiagramConvertible]) -> Parallel {
    let elements = content()
    let p = Parallel(elements: elements.map { $0.toGraphic() })
    p.indexOfCenterElement = centerIndex
    return p
}

/// Creates a labelled capture frame around elements built in the closure.
public func capture(_ text: String = "", @DiagramBuilder _ content: () -> [DiagramConvertible]) -> Decoration {
    let elements = content()
    let elem: Element
    if elements.count == 1 {
        elem = elements[0].toGraphic()
    } else {
        elem = Series(elements: elements.map { $0.toGraphic() })
    }
    return Decoration(element: elem, text: text, style: captureStyle)
}

/// One or more repetitions of elements built in the closure.
public func oneOrMore(loop: DiagramConvertible = skip(), @DiagramBuilder _ content: () -> [DiagramConvertible]) -> Loop {
    let elements = content()
    let elem: Element = elements.count == 1 ? elements[0].toGraphic() : Series(elements: elements.map { $0.toGraphic() })
    return Loop(forward: elem, backward: loop.toGraphic())
}

/// Zero or more repetitions of elements built in the closure.
public func zeroOrMore(loop: DiagramConvertible = skip(), drawSkipBelow: Bool = false, @DiagramBuilder _ content: () -> [DiagramConvertible]) -> Parallel {
    return optional(oneOrMore(loop: loop, content), drawSkipBelow)
}

/// Optional occurrence of elements built in the closure.
public func optional(drawSkipBelow: Bool = false, @DiagramBuilder _ content: () -> [DiagramConvertible]) -> Parallel {
    let elements = content()
    let elem: Element = elements.count == 1 ? elements[0].toGraphic() : Series(elements: elements.map { $0.toGraphic() })
    return optional(elem, drawSkipBelow)
}

/// Creates a diagram image from elements built in the closure.
public func diagram(style: DiagramStyle = DiagramStyle(), scale: CGFloat = 2, @DiagramBuilder _ content: () -> [DiagramConvertible]) -> Image {
    let elements = content()
    return diagram(elements, style: style, scale: scale)
}

/// Produces an ASCII string representation from elements built in the closure.
public func draw(@DiagramBuilder _ content: () -> [DiagramConvertible]) -> String {
    let elements = content()
    if elements.count == 1 {
        return draw(elements[0].toAscii())
    } else {
        return draw(Sequence(elements.map { $0.toAscii() }))
    }
}
