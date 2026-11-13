//
//  Railroad.swift
//  Railroad
//
//  Created by Ulf Akerstedt-Inoue on 2024/03/19.
//

import Foundation


/// A box with rounded sides.
public func terminal(_ text: String) -> Element {
    return Box(text: text, style: terminalStyle)
}

/// A box with straight sides.
public func nonTerminal(_ text: String) -> Element {
    return Box(text: text, style: nonTerminalStyle)
}

/// Text with no box around it; you use this inside repeats.
public func comment(_ text: String) -> Element {
    return Box(text: text, style: commentStyle)
}

/// For things like \s, \w, and so on.
public func characterClass(_ text: String) -> Element {
    return nonTerminal(text)
}

/// For literal text strings inside the regexp.
public func literal(_ text: String) -> Element {
    return terminal(text)
}

/// For start-of-line, etc.
public func special(_ text: String) -> Element {
    return Box(text: text, style: specialStyle)
}

/// Concatenation of two or more elements.
public func sequence(_ elements: Element...) -> Element {
    return Series(elements: elements)
}

/// ? in the regex
///
/// The drawSkipBelow parameter determines whether the skip line is drawn above
/// or below the element; the element itself is always in the center line.
///
/// - Parameters:
///   - element: element description
///   - drawSkipBelow: drawSkipBelow description
/// - Returns:
public func optional(_ element: Element, _ drawSkipBelow: Bool = false) -> Element {
    let p = Parallel()
    if drawSkipBelow {
        p.add(element)
        p.add(Skip())
    } else {
        p.add(Skip())
        p.add(element)
        p.indexOfCenterElement = 1
    }
    return p
}

/// | in the regex
public func choice(_ elements: Element...) -> Element {
    return Parallel(elements: elements)
}

/// | in the regex
///
/// The centerIndex parameter determines which element is drawn on the center line.
/// - Parameters:
///   - centerIndex: centerIndex description
///   - elements:
/// - Returns:
public func choice(_ centerIndex: Int, _ elements: Element...) -> Element {
    let p = Parallel(elements: elements)
    p.indexOfCenterElement = centerIndex
    return p
}

public func skip() -> Element {
    return Skip()
}

/// + in the regex
public func oneOrMore(_ element: Element, _ loop: Element = skip()) -> Element {
    return Loop(forward: element, backward: loop)
}

/// * in the regex
public func zeroOrMore(_ element: Element, _ loop: Element = skip(), _ drawSkipBelow: Bool = false) -> Element {
    return optional(oneOrMore(element, loop), drawSkipBelow)
}

/// A capture group in the regex.
public func capture(_ element: Element, _ text: String) -> Element {
    return Decoration(element: element, text: text, style: captureStyle)
}

/// Draws a railroad diagram as a UIImage.
public func diagram(_ elements: Element...) -> Image {
    var diagramStyle = DiagramStyle()
    diagramStyle.backgroundColor = Color.clear
    diagramStyle.trackLineWidth = 2
    diagramStyle.horizontalSpacing = 12
    diagramStyle.verticalSpacing = 9
    
    let diagram = Diagram(style: diagramStyle)
    let series = Series(elements: elements)
    return diagram.renderImage(element: series, scale: 2)
}




/* each(a, b, c)  produces (A -> B -> C) */
public func each(_ elements: Element...) -> Element {
  return Series(elements: elements)
}

/* Like | in EBNF (choose 1 of) */
public func or(_ elements: Element...) -> Element {
  return Parallel(elements: elements)
}

/* Like ? in EBNF (0 or 1 occurences) */
public func maybe(_ element: Element) -> Element {
  return optional(element)
}

/* Like + in EBNF (1 or more repetitions) */
public func many(_ element: Element, _ loop: Element = Skip()) -> Element {
  return Loop(forward: element, backward: loop)
}

/* Like * in EBNF (0 or more repetitions) */
public func any(_ element: Element, _ loop: Element = Skip()) -> Element {
  return maybe(many(element, loop))
}
