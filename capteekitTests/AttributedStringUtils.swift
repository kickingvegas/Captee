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

import Foundation
import AppKit

struct AttributedStringUtils {
    static let markerFormat: [NSTextList.MarkerFormat] = [
        .box,
        .check,
        .circle,
        .decimal,
        .diamond,
        .disc,
        .hyphen,
        .lowercaseAlpha,
        .lowercaseHexadecimal,
        .lowercaseLatin,
        .lowercaseRoman,
        .octal,
        .square,
        .uppercaseAlpha,
        .uppercaseLatin,
        .uppercaseHexadecimal
    ]
    
    static let markerFormatMap: [NSTextList.MarkerFormat: String] = [
        .box : "☐",
        .check: "✓",
        .circle: "•",
        .diamond: "◆",
        .hyphen: "⁃",
        .square: "▪"
    ]
    
    static func defaultParagraphStyle() -> NSMutableParagraphStyle {
        NSMutableParagraphStyle()
    }
    
    static func listParagraphStyle(_ paragraphStyle: NSMutableParagraphStyle? = nil,
                                   markerFormat: NSTextList.MarkerFormat = .hyphen,
                                   startingItemNumber: Int = 1,
                                   depth: Int=1) -> NSMutableParagraphStyle {
        var pStyle: NSMutableParagraphStyle
        
        if let paragraphStyle = paragraphStyle {
            pStyle = paragraphStyle
        } else {
            pStyle = NSMutableParagraphStyle()
        }
                
        for _ in 1...depth {
            let textList = NSTextList(markerFormat: markerFormat,
                                      startingItemNumber: startingItemNumber)
            pStyle.textLists.append(textList)
        }

        return pStyle
    }
    
    static func attributesDict() -> [NSAttributedString.Key: Any] {
        let result: [NSAttributedString.Key: Any] = [:]
        return result
    }
    
    static func applyParagraphStyle(buf: NSMutableAttributedString, paragraphStyle: NSParagraphStyle) -> NSMutableAttributedString {
        var attributes = attributesDict()
        attributes[.paragraphStyle] = paragraphStyle
        buf.addAttributes(attributes, range: NSRange(location: 0, length: buf.length))
        return buf
    }
    
    static func genNSAttributedStringWithFont(_ buf: String = randomSentence(words: 5), font: NSFont) -> NSAttributedString {
        let paragraphStyle = defaultParagraphStyle()
        var attributes = attributesDict()
        attributes[.paragraphStyle] = paragraphStyle
        attributes[.font] = font
        let nsString = NSAttributedString(string: buf, attributes: attributes)
        return nsString
    }
    
    static func genNSAttributedStringWithFontStyleAttribute(_ buf: String = randomSentence(words: 5), fontStyle: NSAttributedString.Key) -> NSAttributedString {
        let paragraphStyle = AttributedStringUtils.defaultParagraphStyle()
        var attributes = AttributedStringUtils.attributesDict()
        attributes[.paragraphStyle] = paragraphStyle
        attributes[.font] = NSFont.systemFont(ofSize: 12)
        attributes[fontStyle] = NSUnderlineStyle.single.rawValue
        let nsString = NSAttributedString(string: buf, attributes: attributes)
        return nsString
    }
    
    static func strong(_ buf: String) -> NSAttributedString {
        genNSAttributedStringWithFont(buf, font: NSFont.boldSystemFont(ofSize: 12))
    }
    
    static func code(_ buf: String) -> NSAttributedString {
        genNSAttributedStringWithFont(buf, font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular))
    }
    
    static func emphasis(_ buf: String) -> NSAttributedString {
        var result: NSAttributedString
        if let emphasisFont = NSFont(name: "Helvetica-Oblique", size: 12) {
            result = genNSAttributedStringWithFont(buf, font: emphasisFont)
        } else {
            result = NSAttributedString(string: buf)
        }
        return result
    }
    
    static func underline(_ buf: String) -> NSAttributedString {
        genNSAttributedStringWithFontStyleAttribute(buf, fontStyle: .underlineStyle)
    }
    
    static func strikethrough(_ buf: String) -> NSAttributedString {
        genNSAttributedStringWithFontStyleAttribute(buf, fontStyle: .strikethroughStyle)
    }
    
    static func plain(_ buf: String) -> NSAttributedString {
        genNSAttributedStringWithFont(buf, font: NSFont.systemFont(ofSize: 12))
    }
    
        
    static func genAttributedStringWithFont(_ buf: String = randomSentence(words: 5), font: NSFont) throws -> AttributedString {
        let nsString = genNSAttributedStringWithFont(buf, font: font)
        let result = try AttributedString(nsString, including: \.appKit)
        return result
    }
    
    static func genAttributedStringWithFontStyleAttribute(_ buf: String = randomSentence(words: 5), fontStyle: NSAttributedString.Key) throws -> AttributedString {
        let nsString = genNSAttributedStringWithFontStyleAttribute(buf, fontStyle: fontStyle)
        let result = try AttributedString(nsString, including: \.appKit)
        return result
    }
}
