//
// Copyright © 2023-2025 Charles Choi
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

class TranslateNSAttributedStringToMarkup: TranslateToMarkupProtocol {
    let empahasisPat = /oblique|italic/

    func translate(attributedString: AttributedString, markup: MarkupProtocol) -> String {
        var bufList: [String] = []

        for run in attributedString.runs {
            let container = run.attributes
            let runString = String(attributedString.characters[run.range])

            bufList.append(
                contentsOf: processNSAttributeContainer(container: container, runString: runString, markup: markup)
            )
        }

        let firstPass = bufList.joined()

        let secondPassList = firstPass.split(separator: "\n", omittingEmptySubsequences: false)

        var resultList: [String] = []
        secondPassList.forEach { e in
            resultList.append(String(e))
        }

        return resultList.joined(separator: "\n")
    }

    func processNSAttributeContainer(container: AttributeContainer,
                                     runString: String,
                                     markup: MarkupProtocol) -> [String] {

        var bufList: [String] = []
        var buf: String?

        if let link = container.link {
            buf = markup.link(link, description: buf ?? runString)
        }
        
        if let paragraphStyle = container.appKit.paragraphStyle {
            let textLists = paragraphStyle.textLists
            let depth = textLists.count

            if runString != "\n",
               let textList = textLists.last {
                if textList.isOrdered {
                    buf = CapteeUtils.replaceOrderedListMarkers(buf ?? runString, depth: depth)
                } else {
                    buf = CapteeUtils.replaceUnorderedListMarkers(buf ?? runString, depth: depth, marker: "-")
                }
            }
        }

        if let font = container.appKit.font {
            let fontName = font.fontName.lowercased()

            if fontName.contains("bold") {
                buf = markup.strong(buf ?? runString)
            } else if fontName.firstMatch(of: empahasisPat) != nil {
                buf = markup.emphasis(buf ?? runString)
            } else if font.isFixedPitch {
                buf = markup.code(buf ?? runString)
            } else if container.appKit.underlineStyle != nil {
                buf = markup.underline(buf ?? runString)
            } else if container.appKit.strikethroughStyle != nil {
                buf = markup.strikethrough(buf ?? runString)
            } else {
                // TODO: need test for strikethrough
            }
        }

        bufList.append(buf ?? runString)
        return bufList
    }
}
