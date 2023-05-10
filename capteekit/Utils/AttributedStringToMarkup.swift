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


enum AttributedStringFlavor {
    case swift
    case ns
    case unknown
}

class AttributedStringToMarkup: AttributedStringToMarkupProtocol {
    var attributedString: AttributedString
    var previousIntentKind: PresentationIntent.Kind?
    var kindIndexes: [PresentationIntent.Kind: Int] = [:]
    var kindHasChanged: Bool = false
    var idHasChanged: Bool = false

    
    init(_ attributedString: AttributedString) {
        self.attributedString = attributedString
    }
    
    func testSwiftOrNSAttributedString(attributedString: AttributedString) -> AttributedStringFlavor {
        var result: AttributedStringFlavor = .ns
        
        for run in attributedString.runs {
            let container = run.attributes
            if container.presentationIntent != nil {
                result = .swift
                break
            } else if container.paragraphStyle != nil {
                result = .ns
            }
        }
        return result
    }
    
    func toMarkup(format: MarkupFormat) -> String {
        
        var markup: MarkupProtocol
        var translator: TranslateToMarkupProtocol
        
        switch format {
        case .markdown:
            markup = MarkdownDialect()

        case .orgMode:
            markup = OrgDialect()
        }
        
        //!!! Test to see if Swift or NS AttributedString
        
        let attributedStringFlavor = testSwiftOrNSAttributedString(attributedString: attributedString)
        switch attributedStringFlavor {
        case .swift:
            translator = TranslateAttributedStringToMarkup()
        case .ns:
            translator = TranslateNSAttributedStringToMarkup()
        case .unknown:
            // can not translate
            //fatalError("unable to determine attributedStringFlavor")
            let bodyString = String(attributedString.characters[...])
            return bodyString
        }
        
        return translator.translate(attributedString: attributedString, markup: markup)
    }

}
