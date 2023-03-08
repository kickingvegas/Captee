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

extension CapteeManager {
    public func orgProtcolURL(pType: OrgProtocolType, url: URL?, title: String?, body: AttributedString?, template: String?) -> URL? {
        // preconditions:
        // strings must be trimmed of whitespaces and newlines
                
        var orgProtocolComponents = URLComponents()
        orgProtocolComponents.scheme = "org-protocol"
        orgProtocolComponents.host = pType.rawValue
        var queryItems = [URLQueryItem]()
        
        switch pType {
        case .storeLink:
            guard let url = url else {
                return nil
            }
                  
            queryItems.append(URLQueryItem(name: "url", value: url.absoluteString))
        
            if let title = title,
               title != "" {
                queryItems.append(URLQueryItem(name: "title", value: title))
            }

        case .capture:
            if let url = url {
                queryItems.append(URLQueryItem(name: "url", value: url.absoluteString))
            }
            
            if let title = title,
               title != "" {
                queryItems.append(URLQueryItem(name: "title", value: title))
            }

            if let template = template,
               template != "" {
                queryItems.append(URLQueryItem(name: "template", value: template))
            }

            if let body = body {
                // TODO: convert to target format
                let bodyString = String(body.characters[...])
                if bodyString != "" {
                    queryItems.append(URLQueryItem(name: "body", value: bodyString))
                }
            }
        }

        orgProtocolComponents.queryItems = queryItems

        return orgProtocolComponents.url
    }
        
    public func clipboardPayload(url: URL?, title: String?, body: AttributedString?) -> String {
        var bufList = [String]()
        
        if let url = url,
           let title = title,
           title != "" {
            bufList.append("[[\(url.absoluteString)][\(title)]]")
        }
        
        if let body = body {
            // TODO: convert to target format
            let bodyString = String(body.characters[...])
            if bodyString != "" {
                bufList.append(bodyString)
            }
        }
        
        return bufList.joined(separator: "\n")
    }
}
