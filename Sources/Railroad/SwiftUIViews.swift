//
//  SwiftUIViews.swift
//  Railroad
//
//  Created by Ulf Akerstedt-Inoue on 2026/11/13.
//  Copyright © 2026 hakkabon software. All rights reserved.
//

import SwiftUI

// MARK: - SwiftUI Diagram View

/// A SwiftUI view that renders a Railroad diagram natively for macOS and iPadOS/iOS.
public struct RailroadDiagramView: View {
    public let element: Element
    public var style: DiagramStyle
    public var scale: CGFloat?
    
    @Environment(\.displayScale) private var displayScale
    
    /// Initializes a diagram view with an existing diagram element or grammar.
    public init(_ element: DiagramConvertible, style: DiagramStyle = DiagramStyle(), scale: CGFloat? = nil) {
        var effectiveStyle = style
        effectiveStyle.backgroundColor = Color.clear
        effectiveStyle.trackLineWidth = 2
        effectiveStyle.horizontalSpacing = 12
        effectiveStyle.verticalSpacing = 9
        
        self.element = element.toGraphic(style: effectiveStyle)
        self.style = effectiveStyle
        self.scale = scale
    }
    
    /// Initializes a diagram view using the `@DiagramBuilder` result builder closure.
    public init(style: DiagramStyle = DiagramStyle(), scale: CGFloat? = nil, @DiagramBuilder _ content: () -> [DiagramConvertible]) {
        var effectiveStyle = style
        effectiveStyle.backgroundColor = Color.clear
        effectiveStyle.trackLineWidth = 2
        effectiveStyle.horizontalSpacing = 12
        effectiveStyle.verticalSpacing = 9
        
        let elements = content()
        let graphicElements = elements.map { $0.toGraphic(style: effectiveStyle) }
        self.element = graphicElements.count == 1 ? graphicElements[0] : Series(elements: graphicElements)
        self.style = effectiveStyle
        self.scale = scale
    }
    
    public var body: some View {
        let effectiveScale = scale ?? displayScale
        let renderer = Diagram(style: style)
        let renderedImage = renderer.renderImage(element: element, scale: max(1, effectiveScale))
        
        #if os(iOS)
        SwiftUI.Image(uiImage: renderedImage)
            .interpolation(.high)
            .antialiased(true)
        #else
        SwiftUI.Image(nsImage: renderedImage)
            .interpolation(.high)
            .antialiased(true)
        #endif
    }
    
    /// Modifies the diagram style.
    public func diagramStyle(_ newStyle: DiagramStyle) -> RailroadDiagramView {
        var copy = self
        copy.style = newStyle
        return copy
    }
    
    /// Modifies the render scale factor.
    public func diagramScale(_ newScale: CGFloat) -> RailroadDiagramView {
        var copy = self
        copy.scale = newScale
        return copy
    }
}

/// Convenience alias for RailroadDiagramView.
public typealias RailroadView = RailroadDiagramView

// MARK: - SwiftUI Image Generation

extension DiagramConvertible {
    /// Renders the diagram as a SwiftUI `Image`.
    public func swiftUIImage(style: DiagramStyle = DiagramStyle(), scale: CGFloat = 2) -> SwiftUI.Image {
        let graphic = self.toGraphic(style: style)
        let rendered = Diagram(style: style).renderImage(element: graphic, scale: scale)
        #if os(iOS)
        return SwiftUI.Image(uiImage: rendered)
        #else
        return SwiftUI.Image(nsImage: rendered)
        #endif
    }
}
