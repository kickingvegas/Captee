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

public struct CapteePayload {
    public let url: URL?
    public let title: String?
    public let template: String?
    public let body: AttributedString?
    
    public init(url: URL?, title: String?, template: String?, body: AttributedString?) {
        self.url = url
        self.title = title
        self.template = template
        self.body = body
    }
}
