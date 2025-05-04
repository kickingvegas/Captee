//
// Copyright © 2023-2025 Charles Choi
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

import Cocoa
import CapteeKit

public struct Share2EmacsUtils {

    public static func extractPayloadContentFromAppKit(urlField: NSTextField,
                                                       titleField: NSTextField,
                                                       templateField: NSTextField,
                                                       textView: NSTextView) -> CapteePayload {
        var url: URL?
        let urlString: String? = urlField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        var titleString: String? = titleField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        var templateString:String? = templateField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)

        if let urlString2 = urlString {
            url = URL(string: urlString2)
        }

        if titleString == "" {
            titleString = nil
        }

        if templateString == "" {
            templateString = nil
        }

        var body: AttributedString?
        do {
            if let textStorage = textView.textStorage {
                body = try AttributedString(textStorage, including: \.appKit)
            }
        } catch {
            // do nothing
        }

        return CapteePayload(url: url, title: titleString, template: templateString, body: body)
    }
}
