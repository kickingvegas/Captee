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

class TranslateAttributedStringToMarkup: TranslateToMarkupProtocol {
    var previousIntentKind: PresentationIntent.Kind?
    var kindIndexes: [PresentationIntent.Kind: Int] = [:]
    var kindHasChanged: Bool = false
    var idHasChanged: Bool = false

    func translate(attributedString: AttributedString, markup: MarkupProtocol) -> String {
        var bufList: [String] = []
        
        for run in attributedString.runs {
            //print ("😏 \(run)")
            let container = run.attributes
            let runString = String(attributedString.characters[run.range])
            print("😏  '\(runString)'")
            
            bufList.append(
                contentsOf: processSwiftAttributeContainer(container: container, runString: runString, markup: markup)
            )
        }
        
        // Do I need to do this?
        var index: Int = 0

        for (i, value) in bufList.enumerated() {
            if value != "\n\n" {
                index = i
                break
            }
        }

        if index > 0 {
            return bufList[index...].joined()
        } else {
            return bufList.joined()
        }
    }
    
    func processSwiftAttributeContainer(container: AttributeContainer,
                                        runString: String,
                                        markup: MarkupProtocol) -> [String] {
        var bufList: [String] = []
        var buf: String?
        // contain id value for intentType.kind
        
        if let presentationIntent = container.presentationIntent,
           let intentType = presentationIntent.components.first {
            let kind = intentType.kind
  
            // initialize entry in kindIndexes if necessary
            if kindIndexes.index(forKey: kind) == nil {
                kindIndexes[kind] = intentType.identity
            }
            
            kindHasChanged = (previousIntentKind != kind)
                        
            if kindHasChanged {
                // !!!: different kind of instance, add 2 newlines
                bufList.append("\n\n")
            } else {
                // !!!: same kind of instance
                if let oldID = kindIndexes[kind],
                   oldID != intentType.identity {
                    idHasChanged = true
                    kindIndexes[kind] = intentType.identity
                    bufList.append("\n\n")
                }
            }
            
            
            switch kind {
            case .listItem(let ordinal):
                print("PresentationIntent.Kind: \(kind.debugDescription) \(ordinal)")
                
            case .header(let level):
                print("PresentationIntent.Kind: \(kind.debugDescription) \(level)")
      
                if kindHasChanged {
                    buf = markup.header(runString, level: level)
                }
                
            case .paragraph:
                buf = runString

                print("PresentationIntent.Kind: \(kind.debugDescription)")
                
            case .thematicBreak:
                print("PresentationIntent.Kind: \(kind.debugDescription)")
                
            case .unorderedList:
                print("PresentationIntent.Kind: \(kind.debugDescription)")
                
            default:
                print("PresentationIntent.Kind: \(kind.debugDescription)")
            }
            
            previousIntentKind = kind
        }
        
        if let link = container.link {
            buf = markup.link(link, description: buf ?? runString)
        }
            
        if let inlineIntent = container.inlinePresentationIntent {
            switch inlineIntent {
            case .code:
                buf = markup.code(buf ?? runString)
            case .emphasized:
                buf = markup.emphasis(buf ?? runString)
            case .stronglyEmphasized:
                buf = markup.strong(buf ?? runString)
            case .strikethrough:
                buf = markup.strikethrough(buf ?? runString)
            default:
                buf = buf ?? runString
            }
        }
        
        if let buf = buf {
            bufList.append(buf)
        }
        return bufList
    }
    
}
