import XCTest
#if os(OSX)
import Cocoa
#endif

@testable import Railroad

final class RailroadTests: XCTestCase {
    
    func testExample1() throws {
        var commentStyle = BoxStyle()
        commentStyle.shape = .none
        
#if os(iOS)
        commentStyle.textStyle.font = Font.italicSystemFont(ofSize: 18)
#else
        commentStyle.textStyle.font = NSFontManager.shared.font(withFamily: "Verdana", traits: .italicFontMask, weight: 0, size: 18)!
#endif
        
        var boxStyle = BoxStyle()
        boxStyle.shape = .roundedSides
        boxStyle.textStyle.color = Color.darkGray
        boxStyle.borderColor = Color.gray
        boxStyle.textStyle.font = Font.systemFont(ofSize: 24)
        
        var decorationStyle = DecorationStyle()
        decorationStyle.backgroundColor = Color(white: 1, alpha: 0.2)
        decorationStyle.borderSize = 2
        
        var diagramStyle = DiagramStyle()
        diagramStyle.backgroundColor = Color(white: 0.0, alpha: 0.1)
        diagramStyle.margin = EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        diagramStyle.trackLineWidth = 1
        diagramStyle.arrowSize = 9
        
        let box = Box(text: "Happy birthday", style: boxStyle)
        let comment = Box(text: "at least 3 times", style: commentStyle)
        let loop = Loop(forward: box, backward: comment)
        let decoration = Decoration(element: loop, text: "to you!", style: decorationStyle)
        let diagram = Diagram(style: diagramStyle).renderImage(element: decoration, scale: 2)
        
        XCTAssertNotNil(diagram)
    }
    
    func testExample2() throws {
        var myDiagramStyle = DiagramStyle()
        myDiagramStyle.backgroundColor = Color(white: 0.0, alpha: 0.1)
        myDiagramStyle.margin = EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        myDiagramStyle.trackLineWidth = 3
        
        var myBoxStyle = BoxStyle()
        myBoxStyle.shape = .roundedCorners(cornerRadius: 12)
        myBoxStyle.borderSize = 1
        myBoxStyle.backgroundColor = Color.yellow
        myBoxStyle.borderColor = Color.red
        
        var myBoxStyle2 = BoxStyle()
        myBoxStyle2.shape = .pointySides(angle: 30)
        myBoxStyle2.textStyle.color = Color.darkGray
        myBoxStyle2.borderColor = Color.gray
        
        var myBoxStyle3 = BoxStyle()
        myBoxStyle3.shape = .roundedSides
        myBoxStyle3.textStyle.color = Color.darkGray
        myBoxStyle3.borderColor = Color.gray
        //myBoxStyle3.textInsets = EdgeInsets(top: 50, left: 10, bottom: 50, right: 10)
        
        let group1 = Parallel()
        group1.add(Box(text: "He\nllo\naapjes", style: myBoxStyle3))
        group1.add(Box(text: "world!"))
        
        let chain3 = Series()
        chain3.add(Box(text: "a"))
        chain3.add(Box(text: "b"))
        
        let loop1 = Loop(forward: chain3, backward: Box(text: "YO!"))
        
        let chain2 = Series()
        chain2.add(loop1)
        chain2.add(Box(text: "lol\nyeah"))
        
        let group2 = Parallel()
        group2.add(Box(text: "Hello"))
        group2.add(Box(text: "world!"))
        group2.add(Box(text: "yeah!"))
        group2.indexOfCenterElement = 2
        chain2.add(group2)
        
        group1.add(chain2)
        group1.add(Skip())
        
        let chain1 = Series()
        chain1.add(Box(text: "A", style: myBoxStyle))
        chain1.add(Box(text: "B", style: myBoxStyle2))
        chain1.add(group1)
        chain1.add(Box(text: "cde", style: myBoxStyle3))
        
        let diagram = Diagram(style: myDiagramStyle).renderImage(element: chain1, scale: 2)
        
        XCTAssertNotNil(diagram)
    }
    
    func testExample3() throws {
        let strokeColor = Color(red: 0.10, green: 0.41, blue: 1.0, alpha: 1.0)
        let fillColor = strokeColor.withAlphaComponent(0.15)
        
        var boxStyle = BoxStyle()
        boxStyle.shape = .roundedSides
        boxStyle.borderColor = strokeColor
        boxStyle.backgroundColor = fillColor
        boxStyle.textStyle.color = Color(red: 0.05, green: 0.2, blue: 0.5, alpha: 1.0)
        
        let factory = BoxFactory(style: boxStyle)
        
        let chain6 = Series()
        chain6.add(factory.createBox("VALUES"))
        chain6.add(factory.createBox("("))
        chain6.add(Loop(forward: factory.createBox("expr"), backward: factory.createBox(",")))
        chain6.add(factory.createBox(")"))
        
        let group6 = Parallel()
        group6.add(chain6)
        group6.add(factory.createBox("select-stmt"))
        
        let chain5 = Series()
        chain5.add(factory.createBox("("))
        chain5.add(Loop(forward: factory.createBox("column-name"), backward: factory.createBox(",")))
        chain5.add(factory.createBox(")"))
        
        let group5 = Parallel()
        group5.add(chain5)
        group5.add(Skip())
        
        let chain7 = Series()
        chain7.add(group5)
        chain7.add(group6)
        
        let chain8 = Series()
        chain8.add(factory.createBox("DEFAULT"))
        chain8.add(factory.createBox("VALUES"))
        
        let group7 = Parallel()
        group7.add(chain7)
        group7.add(chain8)
        
        let chain4 = Series()
        chain4.add(factory.createBox("database-\nname"))
        chain4.add(factory.createBox("."))
        
        let group4 = Parallel()
        group4.add(chain4)
        group4.add(Skip())
        
        let group3 = Parallel()
        group3.add(factory.createBox("ROLLBACK"))
        group3.add(factory.createBox("ABORT"))
        group3.add(factory.createBox("REPLACE"))
        group3.add(factory.createBox("FAIL"))
        group3.add(factory.createBox("IGNORE"))
        
        let chain3 = Series()
        chain3.add(factory.createBox("OR"))
        chain3.add(group3)
        
        let group2 = Parallel()
        group2.add(Skip())
        group2.add(chain3)
        
        let chain2 = Series()
        chain2.add(factory.createBox("INSERT"))
        chain2.add(group2)
        
        let group1 = Parallel()
        group1.add(chain2)
        group1.add(factory.createBox("REPLACE"))
        
        let chain1 = Series()
        chain1.add(group1)
        chain1.add(factory.createBox("INTO"))
        chain1.add(group4)
        chain1.add(factory.createBox("table-name"))
        chain1.add(group7)
        
        var diagramStyle = DiagramStyle()
        diagramStyle.trackColor = strokeColor
        
        let diagram = Diagram(style: diagramStyle).renderImage(element: chain1, scale: 1)
        
        XCTAssertNotNil(diagram)
    }
    
    func testExample4() throws {
        let diagram = diagram(
            optional(terminal("+"), false),
            choice(
                nonTerminal("name-start char"),
                nonTerminal("escape")
            ),
            capture(
                zeroOrMore(
                    choice(1,
                           nonTerminal("name char"),
                           nonTerminal("escape")
                          ),
                    comment("a comment"),
                    false
                ),
                "capture 2"
            ),
            capture(
                oneOrMore(terminal("x"), comment("5 times")),
                "capture 1"
            )
        )
        XCTAssertNotNil(diagram)
    }
    
    func testJsonObject() throws {
        let diagram = diagram(
            terminal("{"),
            any(
                each(nonTerminal("string"), terminal(":"), nonTerminal("value")),
                terminal(",")),
            terminal("}")
        )
        XCTAssertNotNil(diagram)
    }

    func testJsonNumber() throws {
        let diagram = diagram(
            maybe(terminal("-")),
            or(
                terminal("0"),
                each(terminal("digit\n1-9"), any(terminal("digit")))),
            maybe(
                each(terminal("."), any(terminal("digit")))),
            maybe(
                each(
                    or(terminal("e"), terminal("E")),
                    maybe(or(terminal("+"), terminal("-"))),
                    many(terminal("digit"))
                )
            )
        )
        XCTAssertNotNil(diagram)
    }

    func testRegexFloat() throws {
        func digit() -> Element {
            return characterClass("digit")
        }
        
        let diagram = diagram(
            special("Start of Line"),
            optional(choice(literal("+"), literal("-")), false),
            capture(
                choice(
                    sequence(oneOrMore(digit()), optional(literal("."), false), zeroOrMore(digit())),
                    sequence(literal("."), oneOrMore(digit()))
                ),
                "Capture 1"),
            optional(capture(
                sequence(
                    choice(literal("e"), literal("E")),
                    optional(choice(literal("+"), literal("-"))),
                    oneOrMore(digit())
                ),
                "Capture 2"), false),
            special("End of Line")
        )
        XCTAssertNotNil(diagram)
    }
}
