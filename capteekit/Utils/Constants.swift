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

import Foundation

public struct Constants {
    public static let formatPickerDB: [String: String] = [
        "label.title": NSLocalizedString("Format",
                                         bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                         comment: "Title label for format picker"),
        "radio2.title": NSLocalizedString("Org Mode",
                                          bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                          comment: "Org Mode selection for format picker"),
        "radio1.title": NSLocalizedString("Markdown",
                                          bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                          comment: "Markdown selection for format picker"),
        "label.toolTip": NSLocalizedString("Choose output format",
                                           bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                           comment: "Tool tip for format picker title"),
        "radio2.toolTip": NSLocalizedString("Use Org Mode format",
                                            bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                            comment: "Tool tip for Org Mode format selection"),
        "radio1.toolTip": NSLocalizedString("Use Markdown format",
                                            bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                            comment: "Tool tip for Markdown format selection")
    ]

    public static let payloadPickerDB: [String: String] = [
        "label.title": NSLocalizedString("Payload",
                                         bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                         comment: "Title label for payload picker"),
        "radio1.title": NSLocalizedString("Link",
                                          bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                          comment: "Link selection for payload picker"),
        "radio2.title": NSLocalizedString("Capture",
                                          bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                          comment: "Capture selection for payload picker"),
        "label.toolTip": NSLocalizedString("Choose payload type",
                                           bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                           comment: "Tool tip for payload picker title"),
        "radio1.toolTip": NSLocalizedString("Use link type",
                                            bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                            comment: "Tool tip for link type selection"),
        "radio2.toolTip": NSLocalizedString("Use capture type",
                                            bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                            comment: "Tool tip for capture type selection")
    ]

    public static let transmitPickerDB: [String: String] = [
        "label.title": NSLocalizedString("Use",
                                         bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                         comment: "Title label for transmit picker"),
        "radio2.title": NSLocalizedString("Org Protocol",
                                          bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                          comment: "Org Protocol selection for transmit picker"),
        "radio1.title": NSLocalizedString("Clipboard",
                                          bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                          comment: "Clipboard selection for transmit picker"),
        "label.toolTip": NSLocalizedString("Choose method to share",
                                           bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                           comment: "Tool tip for transmit picker title"),
        "radio2.toolTip": NSLocalizedString("Use Org Protocol to share",
                                            bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                            comment: "Tool tip for Org Protocol selection"),
        "radio1.toolTip": NSLocalizedString("Use Clipboard to share",
                                            bundle: Bundle(identifier: "com.yummymelon.CapteeKit") ?? Bundle.main,
                                            comment: "Tool tip for Clipboard selection")
    ]
}
