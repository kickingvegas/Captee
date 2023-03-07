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
import CapteeKit

class CapteeObservableManager: ObservableObject {
    @Published var urlString: String = ""
    @Published var title: String = ""
    @Published var body: AttributedString = AttributedString("")
    @Published var template: String = ""
    @Published var orgProtocol: OrgProtocolType = .storeLink
    
    var capteeManager = CapteeManager()
    var connectionManager = ConnectionManager()
    
    init() {
        self.template = capteeManager.defaultTemplate
    }
    
    func orgProtocolURL() -> URL? {
        capteeManager.orgProtcolURL(orgProtocol: orgProtocol,
                                    url: URL(string: urlString),
                                    title: title,
                                    body: body,
                                    template: template)
    }
}
