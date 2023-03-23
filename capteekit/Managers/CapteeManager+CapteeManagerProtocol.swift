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
        
    
    public func orgMessage(payloadType: PayloadType, url: URL?, title: String?, body: AttributedString?, template: String?) -> String? {
        var result: String?
        let linkMarkup = orgLinkMarkup(url: url, title: title)
        
        switch payloadType {
        case .link:
            result = linkMarkup
            
        case .capture:
            var bufList = [String]()
            
            if let title = title {
                bufList.append("* " + title)
            }

            if let linkMarkup = linkMarkup {
                bufList.append(linkMarkup)
            }
            
            if let body = body {
                // TODO: convert attributed string to org markup
                let bodyString = String(body.characters[...])
                if bodyString != "" {
                    bufList.append(bodyString)
                }
            }
            
            result = bufList.joined(separator: "\n")
        }
        
        return result
    }
    
    public func markdownMessage(payloadType: PayloadType, url: URL?, title: String?, body: AttributedString?) -> String? {
        var result: String?
        let linkMarkup = markdownLinkMarkup(url: url, title: title)
        
        switch payloadType {
        case .link:
            result = linkMarkup
            
        case .capture:
            var bufList = [String]()
            
            if let title = title {
                bufList.append("# " + title)
            }

            if let linkMarkup = linkMarkup {
                bufList.append(linkMarkup)
            }
            
            if let body = body {
                // TODO: convert attributed string to org markup
                let bodyString = String(body.characters[...])
                if bodyString != "" {
                    bufList.append(bodyString)
                }
            }
            
            result = bufList.joined(separator: "\n")
        }
        
        return result
    }

    
    func orgLinkMarkup(url: URL?, title: String?) -> String? {
        var result: String?
        if let url = url,
           let title = title {
            result = "[[\(url.absoluteString)][\(title)]]"
        } else if let url = url,
                  title == nil {
            result = "[[\(url.absoluteString)]]"
        } else {
            // no link can be defined!
        }
        return result
    }
    
    func markdownLinkMarkup(url: URL?, title: String?) -> String? {
        var result: String?
        if let url = url,
           let title = title {
            result = "[\(title)](\(url.absoluteString))"
        } else if let url = url,
                  title == nil {
            result = "<\(url.absoluteString)>"
        } else {
            // no link can be defined!
        }
        return result
    }
}
