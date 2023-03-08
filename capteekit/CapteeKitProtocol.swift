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

public enum OrgProtocolType: String, Equatable, CaseIterable {
    case storeLink = "store-link"
    case capture
}

public protocol CapteeManagerProtocol {
    /// Generate URL from parameters
    /// - Parameters:
    ///   - pType: Org Protocol type
    ///   - url: URL
    ///   - title: title associated with URL
    ///   - body: body content
    ///   - template: template key
    /// - Returns: Org Procotol URL instance
    func orgProtcolURL(pType: OrgProtocolType, url: URL?, title: String?, body: AttributedString?, template: String?) -> URL?
    
    /// Generate payload string for clipboard
    /// - Parameters:
    ///   - url: URL
    ///   - title: title associated with URL
    ///   - body: body content
    /// - Returns: payload to be put into clipboard
    func clipboardPayload(url: URL?, title: String?, body: AttributedString?) -> String

}

public protocol CapteePersistenceProtocol {
    var defaultTemplate: String { get set }
}
  
