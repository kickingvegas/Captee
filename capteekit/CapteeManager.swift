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
import UniformTypeIdentifiers

public enum OrgProtocolHost: String {
    case storeLink = "store-link"
    case capture
}

public protocol CapteeManagerProtocol {
    func orgProtcolURL(host: OrgProtocolHost, url: URL?, title: String?, body: String?, template: String?) -> URL?
}


public struct CapteeManager: CapteeManagerProtocol {
    
    public init() {
        
    }

    public func hello() {
        print("hello")
        
    }
    
    public func orgProtcolURL(host: OrgProtocolHost, url: URL?, title: String?, body: String?, template: String?) -> URL? {
        // preconditions:
        // strings must be trimmed of whitespaces and newlines

        var orgProtocolComponents = URLComponents()
        orgProtocolComponents.scheme = "org-protocol"
        var queryItems = [URLQueryItem]()
        
        orgProtocolComponents.host = host.rawValue
        
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
        
        if let body = body,
           body != "" {
            queryItems.append(URLQueryItem(name: "body", value: body))
        }
                
        orgProtocolComponents.queryItems = queryItems
        
        if let url = orgProtocolComponents.url {
            return url
        } else {
            return nil
        }
    }
}
