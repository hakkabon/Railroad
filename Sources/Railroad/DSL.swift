//
//  DSL.swift
//  Railroad
//
//  Created by Ulf Akerstedt-Inoue on 2024/03/17.
//

import Foundation

/* Alternative DSL from: https://code.google.com/p/html-railroad-diagram/ */

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
