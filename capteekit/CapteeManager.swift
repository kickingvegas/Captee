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

public enum OrgProtocolType: String, Equatable, CaseIterable {
    case storeLink = "store-link"
    case capture
}

public protocol CapteeManagerProtocol {
    // TODO: body should be of type AttributedString
    func orgProtcolURL(orgProtocol: OrgProtocolType, url: URL?, title: String?, body: String?, template: String?) -> URL?
}

public protocol CapteePersistenceProtocol {
    var defaultTemplate: String { get set }
}
    
public struct CapteeManager: CapteeManagerProtocol, CapteePersistenceProtocol {
    // TODO: do I need these?
    var url: URL?
    var title: String?
    var body: AttributedString?
    var template: String?
        
    public var defaultTemplate: String {
        get {
            if let result = UserDefaults.standard.value(forKey: "template") as? String {
                return result
            } else {
                return "c"
            }
        }
        
        set(newTemplate) {
            UserDefaults.standard.setValue(newTemplate, forKey: "template")
        }
    }
    
    public init() {
        UserDefaults.standard.register(defaults: ["template": "c" ])
    }
    
    public func orgProtcolURL(orgProtocol: OrgProtocolType, url: URL?, title: String?, body: String?, template: String?) -> URL? {
        // preconditions:
        // strings must be trimmed of whitespaces and newlines

        var orgProtocolComponents = URLComponents()
        orgProtocolComponents.scheme = "org-protocol"
        var queryItems = [URLQueryItem]()
        
        orgProtocolComponents.host = orgProtocol.rawValue
        
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
