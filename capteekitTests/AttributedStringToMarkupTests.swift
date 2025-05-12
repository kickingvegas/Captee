//
// Copyright © 2023 Charles Choi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import CapteeKit

typealias asu = AttributedStringUtils

final class AttributedStringToMarkupTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func markdownFontMap() -> [MarkdownStyleDelimiter: NSFont] {
        var fontMap: [MarkdownStyleDelimiter: NSFont] = [:]
        fontMap[.strong] =  NSFont.boldSystemFont(ofSize: 12)
        fontMap[.code] = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        if let emphasisFont = NSFont(name: "Helvetica-Oblique", size: 12) {
         fontMap[.emphasis] = emphasisFont
        }
        return fontMap
    }
    
    func orgFontMap() -> [OrgStyleDelimiter: NSFont] {
        var fontMap: [OrgStyleDelimiter: NSFont] = [:]
        fontMap[.strong] =  NSFont.boldSystemFont(ofSize: 12)
        fontMap[.code] = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        if let emphasisFont = NSFont(name: "Helvetica-Oblique", size: 12) {
         fontMap[.emphasis] = emphasisFont
        }
        return fontMap
    }

    func testExample() throws {
        // OBSOLETE
        let control = internalMarkdown()
        do {
            //let buf = try AttributedString(markdown: control, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            let buf = try AttributedString(markdown: control)
            let markupConverter = AttributedStringToMarkup(buf)
            let output = markupConverter.toMarkup(format: .markdown)
            print("\(output)")
            //XCTAssertEqual(control, output)
        } catch {
            XCTAssertTrue(false)
        }
    }
    
    func test_DoubleLineSpace() throws {
        let control = "mary\n\njane"
        let buf = AttributedString(control)
        let markupConvertor = AttributedStringToMarkup(buf)
        let output = markupConvertor.toMarkup(format: .orgMode)
        // print("\(output)")
        XCTAssertEqual(control, output)
        
        let output2 = markupConvertor.toMarkup(format: .markdown)
        // print("\(output2)")
        XCTAssertEqual(control, output2)
    }
    
    func test_SingleLineSpace() throws {
        let control = "mary\njane"
        let buf = AttributedString(control)
        let markupConvertor = AttributedStringToMarkup(buf)
        let output = markupConvertor.toMarkup(format: .orgMode)
        // print("\(output)")
        XCTAssertEqual(control, output)
        
        let output2 = markupConvertor.toMarkup(format: .markdown)
        // print("\(output2)")
        XCTAssertEqual(control, output2)
    }
    
        
    func internalMarkdown() -> String {
        // OBSOLETE
        let control = "# Hey they *clittiak*.\nI `wanted` to **let** you know ~about~ this.\n\nAlso this is a *[Google](https://www.google.com)* link.\n## Frink this thing"
        return control
    }
    
    func randomNSAttributedSentence(words: Int) -> NSAttributedString {
        let buf = NSMutableAttributedString(string: "")
        let spacer = asu.plain(" ")
                
        for i in 1...words {
            let word = randomString(length: 10)
            
            let delimiter = MarkdownStyleDelimiter.allCases.randomElement()!
            switch delimiter {
            case .emphasis:
                buf.append(asu.emphasis(word))
            case .strong:
                buf.append(asu.strong(word))
            case .code:
                buf.append(asu.code(word))
            case .underline:
                buf.append(asu.underline(word))
            case .strikethrough:
                buf.append(asu.strikethrough(word))
            }

            if i < 8 {
                buf.append(spacer)
            }
        }
        
        buf.append(asu.plain("."))
        let result = NSAttributedString(attributedString: buf)
        return result
    }
    

    func test_markdown_link() throws {
        var attributes = AttributedStringUtils.attributesDict()
        if let url = randomURL() {
            attributes[.link] = url.absoluteString
        }
        attributes[.paragraphStyle] = NSParagraphStyle()
        
        let base = randomSentence(words: 3)
        let buf = NSAttributedString(string: base, attributes: attributes)
        
        do {
            let attrString = try AttributedString(buf, including: \.appKit)
            let markupConverter = AttributedStringToMarkup(attrString)
            let experiment = markupConverter.toMarkup(format: .markdown)
            let control = "[\(base)](\(attributes[.link]!))"
            XCTAssertEqual(control, experiment)

        } catch {
            XCTAssertTrue(false)
        }
    }
    
    func test_org_link() throws {
        var attributes = AttributedStringUtils.attributesDict()
        if let url = randomURL() {
            attributes[.link] = url.absoluteString
        }
        attributes[.paragraphStyle] = NSParagraphStyle()
        
        let base = randomSentence(words: 3)
        let buf = NSAttributedString(string: base, attributes: attributes)
        
        do {
            let attrString = try AttributedString(buf, including: \.appKit)
            let markupConverter = AttributedStringToMarkup(attrString)
            let experiment = markupConverter.toMarkup(format: .orgMode)
            let control = "[[\(attributes[.link]!)][\(base)]]"
            XCTAssertEqual(control, experiment)

        } catch {
            XCTAssertTrue(false)
        }
    }
    
    // TODO: test nested lists for Markdown and Org
    
    func test_markdown_unordered_list_markers() throws {
        let depth = 2
        let base = randomSentence(words: 5)

        for kv in AttributedStringUtils.markerFormatMap {
            let markerFormat = kv.key
            let markerSymbol = kv.value
            let prefix = "\t\(markerSymbol)\t"
            let listParagraphStyle = AttributedStringUtils.listParagraphStyle(
                markerFormat: markerFormat,
                depth: depth
            )
            
            var attributes = AttributedStringUtils.attributesDict()
            attributes[.paragraphStyle] = listParagraphStyle
            let buf = NSAttributedString(string: prefix + base, attributes: attributes)
            
            do {
                let attrString = try AttributedString(buf, including: \.appKit)
                let markupConverter = AttributedStringToMarkup(attrString)
                let experiment = markupConverter.toMarkup(format: .markdown)
                let control = "\(String(repeating: "  ", count: depth-1))- \(base)"
                XCTAssertEqual(control, experiment)
                //print("GO: \(markerFormat.rawValue)\n\(control)\n\(experiment)")

            } catch {
                XCTAssertTrue(false)
            }
        }
    }
    
    func test_org_unordered_list_markers() throws {
        let depth = 2
        let base = randomSentence(words: 5)

        for kv in AttributedStringUtils.markerFormatMap {
            let markerFormat = kv.key
            let markerSymbol = kv.value
            let prefix = "\t\(markerSymbol)\t"
            let listParagraphStyle = AttributedStringUtils.listParagraphStyle(
                markerFormat: markerFormat,
                depth: depth
            )
            
            var attributes = AttributedStringUtils.attributesDict()
            attributes[.paragraphStyle] = listParagraphStyle
            let buf = NSAttributedString(string: prefix + base, attributes: attributes)
            
            do {
                let attrString = try AttributedString(buf, including: \.appKit)
                let markupConverter = AttributedStringToMarkup(attrString)
                let experiment = markupConverter.toMarkup(format: .orgMode)
                let control = "\(String(repeating: "  ", count: depth-1))- \(base)"
                XCTAssertEqual(control, experiment)
                //print("GO: \(markerFormat.rawValue)\n\(control)\n\(experiment)")
                
            } catch {
                XCTAssertTrue(false)
            }
        }
    }
    
    func test_markdown_paragraph() throws {
        var controlList: [String] = []
        let buf = NSMutableAttributedString(string: "")
        let spacer = asu.plain(" ")
        let dialect = MarkdownDialect()
                
        for i in 1...8 {
            let word = randomString(length: 10)
            
            let delimiter = MarkdownStyleDelimiter.allCases.randomElement()!
            switch delimiter {
            case .emphasis:
                buf.append(asu.emphasis(word))
                controlList.append(dialect.emphasis(word))
            case .strong:
                buf.append(asu.strong(word))
                controlList.append(dialect.strong(word))
            case .code:
                buf.append(asu.code(word))
                controlList.append(dialect.code(word))
            case .underline:
                buf.append(asu.underline(word))
                controlList.append(dialect.underline(word))
            case .strikethrough:
                buf.append(asu.strikethrough(word))
                controlList.append(dialect.strikethrough(word))
            }
            if i < 8 {
                buf.append(spacer)
            }
        }
        
        do {
            let attrString = try AttributedString(buf, including: \.appKit)
            print("\(String(attrString.characters[...]))")
            let markupConverter = AttributedStringToMarkup(attrString)
            let experiment = markupConverter.toMarkup(format: .markdown)
            let control = controlList.joined(separator: " ")
            XCTAssertEqual(control, experiment)
        } catch {
            XCTAssertTrue(false)
        }
    }
    
    func test_org_paragraph() throws {
        var controlList: [String] = []
        let buf = NSMutableAttributedString(string: "")
        let spacer = asu.plain(" ")
        let dialect = OrgDialect()
                
        for i in 1...8 {
            let word = randomString(length: 10)
            
            let delimiter = OrgStyleDelimiter.allCases.randomElement()!
            switch delimiter {
            case .emphasis:
                buf.append(asu.emphasis(word))
                controlList.append(dialect.emphasis(word))
            case .strong:
                buf.append(asu.strong(word))
                controlList.append(dialect.strong(word))
            case .code:
                buf.append(asu.code(word))
                controlList.append(dialect.code(word))
            case .underline:
                buf.append(asu.underline(word))
                controlList.append(dialect.underline(word))
            case .strikethrough:
                buf.append(asu.strikethrough(word))
                controlList.append(dialect.strikethrough(word))
            }
            if i < 8 {
                buf.append(spacer)
            }
        }
        
        do {
            let attrString = try AttributedString(buf, including: \.appKit)
            print("\(String(attrString.characters[...]))")
            let markupConverter = AttributedStringToMarkup(attrString)
            let experiment = markupConverter.toMarkup(format: .orgMode)
            let control = controlList.joined(separator: " ")
            XCTAssertEqual(control, experiment)
        } catch {
            XCTAssertTrue(false)
        }
    }
        
    func test_markdown_styles() throws {
        let base = randomSentence(words: 5)
            
        for fontKV in markdownFontMap() {
            do {
                let font = fontKV.value
                let attrString = try AttributedStringUtils.genAttributedStringWithFont(base, font: font)
                let markupConverter = AttributedStringToMarkup(attrString)
                let experiment = markupConverter.toMarkup(format: .markdown)
                
                let delimiter = fontKV.key.rawValue
                let control = "\(delimiter)\(base)\(delimiter)"
                XCTAssertEqual(control, experiment)
    
            } catch {
                XCTAssertTrue(false, "Unexpected condition")
            }
        }
        
        let delimiterToFontStyleMap: [MarkdownStyleDelimiter: NSAttributedString.Key] = [
            .underline: .underlineStyle,
            .strikethrough: .strikethroughStyle
        ]
        
        for pair in delimiterToFontStyleMap {
            let delimiter = pair.key.rawValue
            let fontStyle = pair.value
            
            do {
                let attrString = try AttributedStringUtils.genAttributedStringWithFontStyleAttribute(base, fontStyle: fontStyle)
                let markupConverter = AttributedStringToMarkup(attrString)
                let experiment = markupConverter.toMarkup(format: .markdown)
                let control = "\(delimiter)\(base)\(delimiter)"
                XCTAssertEqual(control, experiment)
            }
        }
    }
    
    func test_org_styles() throws {
        let base = randomSentence(words: 5)
            
        for fontKV in orgFontMap() {
            do {
                let font = fontKV.value
                let attrString = try AttributedStringUtils.genAttributedStringWithFont(base, font: font)
                let markupConverter = AttributedStringToMarkup(attrString)
                let experiment = markupConverter.toMarkup(format: .orgMode)
                
                let delimiter = fontKV.key.rawValue
                let control = "\(delimiter)\(base)\(delimiter)"
                XCTAssertEqual(control, experiment)
    
            } catch {
                XCTAssertTrue(false, "Unexpected condition")
            }
        }
        
        let delimiterToFontStyleMap: [OrgStyleDelimiter: NSAttributedString.Key] = [
            .underline: .underlineStyle,
            .strikethrough: .strikethroughStyle
        ]
        
        for pair in delimiterToFontStyleMap {
            let delimiter = pair.key.rawValue
            let fontStyle = pair.value
            
            do {
                let attrString = try AttributedStringUtils.genAttributedStringWithFontStyleAttribute(base, fontStyle: fontStyle)
                let markupConverter = AttributedStringToMarkup(attrString)
                let experiment = markupConverter.toMarkup(format: .orgMode)
                let control = "\(delimiter)\(base)\(delimiter)"
                XCTAssertEqual(control, experiment)
            }
        }
    }
}
