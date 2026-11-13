# Railroad

**Railroad** is a Swift package for creating visual syntax and railroad diagrams for **BNF grammars** and **regular expressions**, rendering to:
- **SwiftUI Views** (`RailroadDiagramView` / `RailroadView`, `swiftUIImage`)
- **UIKit / AppKit Images** (`UIImage` on iOS/iPadOS, `NSImage` on macOS)
- **ASCII Text** (clean Unicode box-drawing characters)

---

## Features

- **SwiftUI Native**: First-class SwiftUI component (`RailroadDiagramView` / `RailroadView`) and `SwiftUI.Image` export.
- **Function Builder Idiom**: Declarative `@DiagramBuilder` syntax for assembling diagrams cleanly with blocks/closures.
- **BNF Grammars**: Full ASCII diagramming preserved 100% as-is, with added ability to render SwiftUI views and graphical diagrams (`UIImage` / `NSImage`).
- **Regular Expressions**: Consolidated API for regular expressions (`literal`, `characterClass`, `special`, `capture`, `choice`, `sequence`, `oneOrMore`, `zeroOrMore`, `optional`, plus DSL aliases `each`, `or`, `maybe`, `many`, `any`) producing SwiftUI views, graphical images, and ASCII diagrams.
- **Cross-Platform**: Seamlessly runs on **macOS** and **iPadOS / iOS**.
- **Interactive Demo App**: Bundled SwiftUI demo app demonstrating BNF and Regex diagrams with live ASCII preview and style controls.

---

## Installation

Add Railroad to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/...", from: "1.0.0")
]
```

---

## SwiftUI & Function Builder API

### 1. Declarative SwiftUI View (`RailroadView`)

Using the function builder idiom directly in your SwiftUI view hierarchy:

```swift
import SwiftUI
import Railroad

struct SQLQueryDiagramView: View {
    var body: some View {
        RailroadView {
            terminal("SELECT")
            choice {
                terminal("*")
                sequence {
                    nonTerminal("column_name")
                    repeater(sequence([terminal(","), nonTerminal("column_name")]))
                }
            }
            terminal("FROM")
            nonTerminal("table_name")
            optional {
                terminal("WHERE")
                nonTerminal("condition")
            }
        }
    }
}
```

### 2. Regular Expressions with Function Builders

```swift
struct URLRegexView: View {
    var body: some View {
        RailroadView {
            special("^")
            choice {
                literal("http")
                literal("https")
            }
            literal("://")
            capture("domain") {
                oneOrMore {
                    characterClass("\\w")
                }
            }
            optional(drawSkipBelow: false) {
                literal(":")
                oneOrMore {
                    characterClass("\\d")
                }
            }
            special("$")
        }
    }
}
```

### 3. Assembling Elements via Result Builders

You can also use function builders outside SwiftUI views:

```swift
// Build a diagram structure with result builder closures
let diagramElement = sequence {
    terminal("BEGIN")
    choice {
        nonTerminal("statement_a")
        nonTerminal("statement_b")
    }
    terminal("COMMIT")
}

// Convert to SwiftUI Image:
let swiftImage: SwiftUI.Image = diagramElement.swiftUIImage(scale: 2)

// Convert to ASCII String:
let ascii: String = draw(diagramElement)

// Or draw directly using a builder block:
let asciiOutput = draw {
    terminal("A")
    choice {
        terminal("B")
        terminal("C")
    }
    terminal("D")
}
```

---

## BNF Grammars (Classic Functional API)

### ASCII Diagrams
```swift
import Railroad

let grammar = sequence([
    terminal("SELECT"),
    choice([
        terminal("*"),
        sequence([
            nonTerminal("column_name"),
            repeater(sequence([terminal(","), nonTerminal("column_name")]))
        ])
    ]),
    terminal("FROM"),
    nonTerminal("table_name")
])

// Produce ASCII diagram string
let ascii = draw(grammar)
print(ascii)
```

Output:
```
                                ╭───╮                
                       ╭────────┤ * ├────────╮       
                       │        ╰───╯        │       
 ╭────────╮            │ ┏━━━━━━━━━━━━━┓     │  ╭──────╮  ┏━━━━━━━━━━━━┓ 
─┤ SELECT ├────────────┼─┨ column_name ┠─────┼──┤ FROM ├──┨ table_name ┠─
 ╰────────╯            │ ┗━━━━━━━━━━━━━┛   │ │  ╰──────╯  ┗━━━━━━━━━━━━┛ 
                       │  ╭───╮ ┏━━━━━━━━━━━━━┓│     │                   
                       ╰──┤ , ├─┨ column_name ┠╯     │                   
                          ╰───╯ ┗━━━━━━━━━━━━━┛←─────╯                   
```

### Graphical Diagrams (UIKit / iPadOS & macOS)
```swift
// Produce UIImage (iOS/iPadOS) or NSImage (macOS)
let image = diagram(grammar)

// Or with custom styling & scale:
let customImage = grammar.renderImage(style: DiagramStyle(), scale: 2)
```

---

## Running the SwiftUI Demo App

The package includes a full SwiftUI test app (`RailroadDemo`) for macOS and iPadOS displaying:
- SQL Query BNF diagram
- JSON Object BNF diagram
- URL Pattern Regex diagram
- Floating Point Regex diagram with DSL aliases
- Live graphical rendering with controls for arrowheads, line width, and a synchronized ASCII preview.

To run on macOS:
```bash
swift run RailroadDemo
```

---

## Architecture

- **`SwiftUIViews.swift`**: SwiftUI integration, `RailroadDiagramView` / `RailroadView`, and `swiftUIImage()` export.
- **`DiagramBuilder.swift`**: `@DiagramBuilder` result builder implementation and builder-closure overloads for `sequence`, `choice`, `capture`, `oneOrMore`, `zeroOrMore`, `optional`, and `draw`.
- **`DiagramElements.swift`**: Character grid coordinate system, Unicode box drawing, and ASCII diagram elements (`Terminal`, `NonTerminal`, `Special`, `Comment`, `Group`, `Sequence`, `Choice`, `Stack`, `HorizontalChoice`, `AsciiSkip`).
- **`GrammarDiagram.swift`**: BNF grammar builder functions and ASCII canvas rendering (`draw`).
- **`RailroadElements.swift`**: CoreGraphics geometry engine, font measuring, layout calculations, and styling (`Box`, `Series`, `Parallel`, `Loop`, `Decoration`, `Skip`, `Diagram`). Supports both UIKit (`UIImage`) and AppKit (`NSImage`).
- **`RailroadDiagram.swift`**: Consolidated API for regular expressions and DSL convenience methods.
- **`DiagramBridge.swift`**: `DiagramConvertible` protocol bridging ASCII and Graphical elements bidirectionally.
- **`Util.swift`**: Exporting and saving image files to disk.

---

## License

Copyright © hakkabon software. All rights reserved.
