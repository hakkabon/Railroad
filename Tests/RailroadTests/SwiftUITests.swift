import XCTest
import SwiftUI
@testable import Railroad

final class SwiftUITests: XCTestCase {
    
    // MARK: - Result Builder Tests
    
    func testResultBuilderSequenceAndChoice() throws {
        // Construct diagram using @DiagramBuilder syntax
        let diagram = sequence {
            terminal("SELECT")
            choice {
                terminal("*")
                nonTerminal("column_name")
            }
            terminal("FROM")
            nonTerminal("table_name")
        }
        
        XCTAssertNotNil(diagram)
        XCTAssertEqual(diagram.elements.count, 4)
        
        let ascii = draw(diagram)
        XCTAssertTrue(ascii.contains("SELECT"))
        XCTAssertTrue(ascii.contains("FROM"))
        XCTAssertTrue(ascii.contains("table_name"))
    }
    
    func testResultBuilderRegex() throws {
        let regex = sequence {
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
        
        XCTAssertNotNil(regex)
        
        let ascii = draw(regex)
        XCTAssertTrue(ascii.contains("http"))
        XCTAssertTrue(ascii.contains("domain"))
        
        let image = diagram(regex)
        XCTAssertNotNil(image)
    }
    
    func testResultBuilderDrawFunction() throws {
        let ascii = draw {
            terminal("A")
            choice {
                terminal("B")
                terminal("C")
            }
            terminal("D")
        }
        
        XCTAssertFalse(ascii.isEmpty)
        XCTAssertTrue(ascii.contains("A"))
        XCTAssertTrue(ascii.contains("B"))
        XCTAssertTrue(ascii.contains("C"))
        XCTAssertTrue(ascii.contains("D"))
    }
    
    // MARK: - SwiftUI View & Image Tests
    
    func testRailroadDiagramViewInitialization() throws {
        let view = RailroadDiagramView {
            terminal("BEGIN")
            choice {
                nonTerminal("statement_a")
                nonTerminal("statement_b")
            }
            terminal("COMMIT")
        }
        
        XCTAssertNotNil(view.body)
    }
    
    func testSwiftUIImageExtension() throws {
        let bnf = sequence([
            terminal("{"),
            nonTerminal("pair"),
            terminal("}")
        ])
        
        let swiftUIImage: SwiftUI.Image = bnf.swiftUIImage(scale: 2)
        XCTAssertNotNil(swiftUIImage)
    }
}

