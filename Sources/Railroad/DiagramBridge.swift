//
//  DiagramBridge.swift
//  Railroad
//
//  Created by Ulf Akerstedt-Inoue on 2026/11/13.
//  Copyright © 2026 hakkabon software. All rights reserved.
//

import Foundation
import CoreGraphics

// MARK: - DiagramConvertible Protocol

public protocol DiagramConvertible {
    func toGraphic(style: DiagramStyle) -> Element
    func toAscii() -> DiagramElement
}

extension DiagramConvertible {
    public func toGraphic() -> Element {
        return toGraphic(style: DiagramStyle())
    }
}

// MARK: - DiagramElement Conformance

extension DiagramElement {
    public func toGraphic(style: DiagramStyle = DiagramStyle()) -> Element {
        if let term = self as? Terminal {
            return Box(text: term.name, style: terminalStyle)
        } else if let nonTerm = self as? NonTerminal {
            return Box(text: nonTerm.name, style: nonTerminalStyle)
        } else if let spec = self as? Special {
            return Box(text: spec.name, style: specialStyle)
        } else if let com = self as? Comment {
            return Box(text: com.comment, style: commentStyle)
        } else if let comLine = self as? CommentWithLine {
            return Box(text: comLine.comment, style: commentStyle)
        } else if self is AsciiSkip {
            return Skip()
        } else if let seq = self as? Sequence {
            return Series(elements: seq.elements.map { $0.toGraphic(style: style) })
        } else if let ch = self as? Choice {
            // Check for optional pattern: Choice([AsciiSkip, elem], defaultChoice: 1)
            if ch.elements.count == 2 && ch.defaultChoice == 1 && ch.elements[0] is AsciiSkip {
                let p = Parallel()
                p.add(Skip())
                p.add(ch.elements[1].toGraphic(style: style))
                p.indexOfCenterElement = 1
                return p
            }
            // Check for repeater pattern: Choice([elem, Sequence([inBetween, AsciiSkip])])
            if ch.elements.count == 2 && ch.defaultChoice == 0,
               let loopSeq = ch.elements[1] as? Sequence,
               loopSeq.elements.count >= 1 {
                let fwd = ch.elements[0].toGraphic(style: style)
                let bwdItems = loopSeq.elements.filter { !($0 is AsciiSkip) }
                let bwd: Element
                if bwdItems.isEmpty {
                    bwd = Skip()
                } else if bwdItems.count == 1 {
                    bwd = bwdItems[0].toGraphic(style: style)
                } else {
                    bwd = Series(elements: bwdItems.map { $0.toGraphic(style: style) })
                }
                return Loop(forward: fwd, backward: bwd)
            }
            let p = Parallel(elements: ch.elements.map { $0.toGraphic(style: style) })
            p.indexOfCenterElement = ch.defaultChoice
            return p
        } else if let grp = self as? Group {
            return Decoration(element: grp.element.toGraphic(style: style), text: grp.label, style: captureStyle)
        } else if let diag = self as? AsciiDiagram {
            return diag.element.toGraphic(style: style)
        } else if let stk = self as? Stack {
            return Series(elements: stk.elements.map { $0.toGraphic(style: style) })
        } else if let hch = self as? HorizontalChoice {
            return Parallel(elements: hch.elements.map { $0.toGraphic(style: style) })
        } else {
            return Box(text: "", style: commentStyle)
        }
    }
    
    public func toAscii() -> DiagramElement {
        return self
    }
    
    public func renderImage(style: DiagramStyle = DiagramStyle(), scale: CGFloat = 2) -> Image {
        let graphic = self.toGraphic(style: style)
        let renderer = Diagram(style: style)
        return renderer.renderImage(element: graphic, scale: scale)
    }
}

// Make standard DiagramElements conform to DiagramConvertible
extension Terminal: DiagramConvertible {}
extension NonTerminal: DiagramConvertible {}
extension Special: DiagramConvertible {}
extension Comment: DiagramConvertible {}
extension CommentWithLine: DiagramConvertible {}
extension AsciiSkip: DiagramConvertible {}
extension Group: DiagramConvertible {}
extension AsciiDiagram: DiagramConvertible {}
extension Sequence: DiagramConvertible {}
extension Choice: DiagramConvertible {}
extension Stack: DiagramConvertible {}
extension HorizontalChoice: DiagramConvertible {}

// MARK: - Element Conformance

extension Element: DiagramConvertible {
    public func toGraphic(style: DiagramStyle = DiagramStyle()) -> Element {
        return self
    }
    
    public func toAscii() -> DiagramElement {
        if let box = self as? Box {
            switch box.style.shape {
            case .roundedSides:
                return Terminal(box.text)
            case .rectangle, .roundedCorners:
                return NonTerminal(box.text)
            case .pointySides:
                return Special(box.text)
            case .none:
                return Comment(box.text)
            }
        } else if let series = self as? Series {
            return Sequence(series.elements.map { $0.toAscii() })
        } else if let parallel = self as? Parallel {
            return Choice(parallel.elements.map { $0.toAscii() }, defaultChoice: parallel.indexOfCenterElement)
        } else if let loop = self as? Loop {
            return Choice([
                loop.forward.toAscii(),
                Sequence([loop.backward.toAscii(), AsciiSkip(BoxChars.left)])
            ], defaultChoice: 0)
        } else if let decoration = self as? Decoration {
            return Group(decoration.element.toAscii(), label: decoration.text)
        } else if self is Skip {
            return AsciiSkip(BoxChars.right)
        } else {
            return Comment("")
        }
    }
    
    public func drawAscii() -> String {
        return draw(self.toAscii())
    }
    
    public func renderImage(style: DiagramStyle = DiagramStyle(), scale: CGFloat = 2) -> Image {
        let renderer = Diagram(style: style)
        return renderer.renderImage(element: self, scale: scale)
    }
}

// MARK: - Global Rendering Functions

public func draw(_ element: Element) -> String {
    return draw(element.toAscii())
}

public func drawAscii(_ element: DiagramConvertible) -> String {
    return draw(element.toAscii())
}

public func renderImage(_ element: DiagramConvertible, style: DiagramStyle = DiagramStyle(), scale: CGFloat = 2) -> Image {
    let graphic = element.toGraphic(style: style)
    let renderer = Diagram(style: style)
    return renderer.renderImage(element: graphic, scale: scale)
}

public func diagram(_ elements: DiagramConvertible...) -> Image {
    return diagram(elements)
}

public func diagram(_ elements: [DiagramConvertible], style: DiagramStyle = DiagramStyle(), scale: CGFloat = 2) -> Image {
    var diagramStyle = style
    diagramStyle.backgroundColor = Color.clear
    diagramStyle.trackLineWidth = 2
    diagramStyle.horizontalSpacing = 12
    diagramStyle.verticalSpacing = 9
    
    let graphicElements = elements.map { $0.toGraphic(style: diagramStyle) }
    let series = Series(elements: graphicElements)
    let renderer = Diagram(style: diagramStyle)
    return renderer.renderImage(element: series, scale: scale)
}
