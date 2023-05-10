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

import SwiftUI

public struct CapteeUtils {
    static let unorderedListPat = /\t(?<marker>[⁃▪•✓◦*+\-☐◆])\t/
    
    static let orderedListPat = /\t(?<marker>[\d|\p{Letter}]*)[.)]\t/
    
    public static func extractPayloadContent(urlString: String,
                                             titleString: String,
                                             templateString: String,
                                             body: AttributedString) -> CapteePayload {
        
        let titleBuf: String? = (titleString != "") ? titleString : nil
        let templateBuf: String? = (templateString != "") ? templateString : nil
        let url: URL? = URL(string: urlString)
        
        return CapteePayload(url: url, title: titleBuf, template: templateBuf, body: body)
    }
    
    public static func validateURL(string: String) -> Bool {
        var test = true
        
        if let urlComponents = URLComponents(string: string) {
            if let scheme = urlComponents.scheme {
                if !(["http", "https", "file"].contains(scheme)) {
                    test = false
                }
            } else {
                test = false
            }
            
            if urlComponents.url == nil {
                test = false
            }
        } else {
            test = false
        }
        
        return test
    }
    
    public static func replaceOrderedListMarkers(_ buf: String, depth: Int=1) -> String {
        guard depth >= 1 else {
            fatalError("depth is not at least value 1")
        }
        
        let regex = CapteeUtils.orderedListPat
        var resultList: [String] = []
        
        let bufList = buf.split(separator: "\n", omittingEmptySubsequences: false)
        bufList.forEach { e in
            if let match = e.firstMatch(of: regex) {
                let template = "\(String(repeating: "  ", count: depth - 1 ))\(String(match.marker)). "
                resultList.append(String(e.replacing(regex, with: template)))
            } else {
                resultList.append(String(e))
            }
        }
        
        return resultList.joined(separator: "\n")
    }
    
    public static func replaceUnorderedListMarkers(_ buf: String, depth: Int=1, marker: String?=nil) -> String {
        guard depth >= 1 else {
            fatalError("depth is not at least value 1")
        }
        
        // !!!: Handles corner case where list item is badly formed.
        let fancyMarkers = ["⁃", "▪", "•", "✓", "◦", "◆"]
        if fancyMarkers.contains(buf) {
            return "\(String(repeating: "  ", count: depth - 1 ))\(marker ?? buf)"
        }
        
        let regex = CapteeUtils.unorderedListPat
        var resultList: [String] = []
        
        let bufList = buf.split(separator: "\n", omittingEmptySubsequences: false)
        bufList.forEach { e in
            if let match = e.firstMatch(of: regex) {
                let template = "\(String(repeating: "  ", count: depth - 1 ))\(marker ?? String(match.marker)) "
                resultList.append(String(e.replacing(regex, with: template)))
            } else {
                resultList.append(String(e))
            }
        }
        
        return resultList.joined(separator: "\n")
    }
 
    
    public static func delimitString(buf: String, delimiter: String, trailing: Bool = true) -> String {
        
        guard buf != "\n" else { return buf }
        
        let bufList = buf.split(separator: "\n", omittingEmptySubsequences: false)
        var resultList: [String] = []
        
                
        bufList.forEach { item in
            if item != "" {
                resultList.append(delimiter)
                resultList.append(String(item))
                if trailing {
                    resultList.append(delimiter)
                }
            } else {
                resultList.append(String(item))
            }
        }
        
        var result = resultList.joined()
        
        if buf.last == "\n" {
            result += "\n"
        }
        
        return result
    }
}
