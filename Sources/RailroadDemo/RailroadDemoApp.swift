//
//  RailroadDemoApp.swift
//  RailroadDemo
//
//  Created by Ulf Akerstedt-Inoue on 2026/11/13.
//  Copyright © 2026 hakkabon software. All rights reserved.
//

import SwiftUI
import Railroad

@main
struct RailroadDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

enum DemoExample: String, CaseIterable, Identifiable {
    case sqlQuery = "SQL Query (BNF)"
    case jsonObject = "JSON Object (BNF)"
    case urlRegex = "URL Pattern (Regex)"
    case floatRegex = "Float Pattern (Regex DSL)"
    
    var id: String { rawValue }
}

struct ContentView: View {
    @State private var selectedExample: DemoExample = .sqlQuery
    @State private var showAscii = true
    @State private var arrowHeads = true
    @State private var trackLineWidth: Double = 2.0
    
    private var diagramStyle: DiagramStyle {
        var style = DiagramStyle()
        style.backgroundColor = Railroad.Color.clear
        style.arrowHeads = arrowHeads
        style.trackLineWidth = CGFloat(trackLineWidth)
        style.horizontalSpacing = 16
        style.verticalSpacing = 12
        return style
    }
    
    var body: some View {
        #if os(macOS)
        NavigationView {
            sidebar
            detailView
        }
        .frame(minWidth: 800, minHeight: 600)
        #else
        NavigationView {
            sidebar
            detailView
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        #endif
    }
    
    private var sidebar: some View {
        List {
            Section(header: Text("Examples")) {
                ForEach(DemoExample.allCases) { example in
                    Button(action: { selectedExample = example }) {
                        HStack {
                            Text(example.rawValue)
                                .fontWeight(selectedExample == example ? .bold : .regular)
                            Spacer()
                            if selectedExample == example {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Section(header: Text("Options")) {
                Toggle("Show ASCII Preview", isOn: $showAscii)
                Toggle("Arrow Heads", isOn: $arrowHeads)
                VStack(alignment: .leading) {
                    Text("Line Width: \(Int(trackLineWidth))")
                    Slider(value: $trackLineWidth, in: 1...4, step: 1)
                }
            }
        }
        .navigationTitle("Railroad Diagrams")
    }
    
    private var detailView: some View {
        VStack(spacing: 0) {
            // Visual Diagram Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SwiftUI Graphic Rendering")
                        .font(.headline)
                    Spacer()
                }
                .padding([.top, .horizontal])
                
                ScrollView([.horizontal, .vertical]) {
                    currentDiagramView
                        .padding(24)
                        .background(SwiftUI.Color.secondary.opacity(0.08))
                        .cornerRadius(12)
                        .padding([.horizontal, .bottom])
                }
            }
            
            // ASCII Representation Section
            if showAscii {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ASCII Representation")
                            .font(.headline)
                        Spacer()
                    }
                    .padding([.top, .horizontal])
                    
                    ScrollView([.horizontal, .vertical]) {
                        Text(currentAsciiString)
                            .font(.system(.body, design: .monospaced))
                            .padding(16)
                            .background(SwiftUI.Color.secondary.opacity(0.05))
                            .cornerRadius(8)
                            .padding([.horizontal, .bottom])
                    }
                    .frame(maxHeight: 220)
                }
            }
        }
        .navigationTitle(selectedExample.rawValue)
    }
    
    // MARK: - Example 1: BNF Grammar using @DiagramBuilder (SQL Query)
    @ViewBuilder
    private var sqlQueryView: some View {
        RailroadView(style: diagramStyle) {
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
    
    private var sqlQueryAscii: String {
        draw {
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
    
    // MARK: - Example 2: BNF Grammar (JSON Object)
    @ViewBuilder
    private var jsonObjectView: some View {
        RailroadView(style: diagramStyle) {
            terminal("{")
            choice {
                skip()
                sequence {
                    nonTerminal("string")
                    terminal(":")
                    nonTerminal("value")
                    repeater(
                        sequence([terminal(","), nonTerminal("string"), terminal(":"), nonTerminal("value")])
                    )
                }
            }
            terminal("}")
        }
    }
    
    private var jsonObjectAscii: String {
        draw {
            terminal("{")
            choice {
                skip()
                sequence {
                    nonTerminal("string")
                    terminal(":")
                    nonTerminal("value")
                    repeater(
                        sequence([terminal(","), nonTerminal("string"), terminal(":"), nonTerminal("value")])
                    )
                }
            }
            terminal("}")
        }
    }
    
    // MARK: - Example 3: Regex with Function Builder (URL Matcher)
    @ViewBuilder
    private var urlRegexView: some View {
        RailroadView(style: diagramStyle) {
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
    
    private var urlRegexAscii: String {
        draw {
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
    
    // MARK: - Example 4: Regex with DSL Aliases (Float Pattern)
    @ViewBuilder
    private var floatRegexView: some View {
        RailroadView(style: diagramStyle) {
            maybe(literal("-"))
            or(
                literal("0"),
                each(characterClass("[1-9]"), any(characterClass("[0-9]")))
            )
            maybe(
                each(literal("."), many(characterClass("[0-9]")))
            )
        }
    }
    
    private var floatRegexAscii: String {
        draw {
            maybe(literal("-"))
            or(
                literal("0"),
                each(characterClass("[1-9]"), any(characterClass("[0-9]")))
            )
            maybe(
                each(literal("."), many(characterClass("[0-9]")))
            )
        }
    }
    
    // MARK: - View Routing
    @ViewBuilder
    private var currentDiagramView: some View {
        switch selectedExample {
        case .sqlQuery:
            sqlQueryView
        case .jsonObject:
            jsonObjectView
        case .urlRegex:
            urlRegexView
        case .floatRegex:
            floatRegexView
        }
    }
    
    private var currentAsciiString: String {
        switch selectedExample {
        case .sqlQuery:
            return sqlQueryAscii
        case .jsonObject:
            return jsonObjectAscii
        case .urlRegex:
            return urlRegexAscii
        case .floatRegex:
            return floatRegexAscii
        }
    }
}
