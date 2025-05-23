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

class CXTextViewValidator: NSObject, NSTextViewDelegate {
    let viewModel: CapteeViewModel

    init(_ viewModel: CapteeViewModel) {
        self.viewModel = viewModel
    }


    func textDidChange(_ notification: Notification) {
        guard notification.object is NSTextView else {
            return
        }

        if let targetObject = notification.object {
            let textView = targetObject as! NSTextView

            if let textStorage = textView.textStorage {

                do {
                    let body = try AttributedString(textStorage, including: \.appKit)
                    //let bodyString = String(body.characters[...])
                    //print("#### hey textView changed <<<< \(bodyString)")
                    viewModel.body = body

                } catch {
                    // TODO: need to handle properly
                    print("ERROR: nothing in textStorage")
                }
            }
        }
    }
}
