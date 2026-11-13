import XCTest
@testable import Railroad

final class ConsolidatedDiagramTests: XCTestCase {
    
    // MARK: - BNF Grammars producing UIKit/AppKit Diagrams
    
    func testBNFGrammarToUIKitImage() throws {
        // Construct a BNF grammar using the BNF grammar API
        let bnf = sequence([
            terminal("SELECT"),
            choice([
                terminal("*"),
                sequence([
                    nonTerminal("column_name"),
                    repeater(
                        sequence([terminal(","), nonTerminal("column_name")])
                    )
                ])
            ]),
            terminal("FROM"),
            nonTerminal("table_name"),
            optional(
                sequence([
                    terminal("WHERE"),
                    nonTerminal("condition")
                ])
            )
        ])
        
        // Render as ASCII diagram
        let asciiOutput = draw(bnf)
        XCTAssertFalse(asciiOutput.isEmpty)
        print("--- BNF ASCII Diagram ---")
        print(asciiOutput)
        
        // Render as UIKit / AppKit Image diagram
        let imageOutput = diagram(bnf)
        XCTAssertNotNil(imageOutput)
        
        let customImage = bnf.renderImage(style: DiagramStyle(), scale: 2)
        XCTAssertNotNil(customImage)
    }
    
    // MARK: - Regular Expressions producing ASCII Diagrams
    
    func testRegexToAscii() throws {
        // Construct a regular expression using the consolidated Regex API
        let regex = sequence(
            special("^"),
            choice(
                literal("http"),
                literal("https")
            ),
            literal("://"),
            capture(
                oneOrMore(characterClass("\\w")),
                "domain"
            ),
            optional(
                sequence(
                    literal(":"),
                    oneOrMore(characterClass("\\d"))
                ),
                false
            ),
            special("$")
        )
        
        // 1. Render to UIKit/AppKit Image
        let image = diagram(regex)
        XCTAssertNotNil(image)
        
        // 2. Render to ASCII String
        let ascii = draw(regex)
        XCTAssertFalse(ascii.isEmpty)
        print("--- Regex ASCII Diagram ---")
        print(ascii)
        
        // Verify ASCII diagram contains key literal and character class texts
        XCTAssertTrue(ascii.contains("http"))
        XCTAssertTrue(ascii.contains("https"))
        XCTAssertTrue(ascii.contains("://"))
        XCTAssertTrue(ascii.contains("\\w"))
        XCTAssertTrue(ascii.contains("domain"))
    }
    
    // MARK: - Regex DSL Aliases producing both ASCII and Graphic
    
    func testRegexDSLAliases() throws {
        let pattern = each(
            maybe(literal("-")),
            or(
                literal("0"),
                each(characterClass("[1-9]"), any(characterClass("[0-9]")))
            ),
            maybe(each(literal("."), many(characterClass("[0-9]"))))
        )
        
        // Test graphic output
        let img = diagram(pattern)
        XCTAssertNotNil(img)
        
        // Test ASCII output
        let ascii = pattern.drawAscii()
        XCTAssertFalse(ascii.isEmpty)
        print("--- Number Regex ASCII ---")
        print(ascii)
    }
}

