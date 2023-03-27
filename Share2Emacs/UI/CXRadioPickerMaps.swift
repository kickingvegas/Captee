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
import CapteeKit

struct CXRadioPickerMaps {
    static let formatMap: [CXRadioPickerSelected: MarkupFormat] = [
        .radio1 : .orgMode,
        .radio2 : .markdown
    ]
    
    static let inverseFormatMap: [MarkupFormat: CXRadioPickerSelected] = [
        .orgMode: .radio1,
        .markdown: .radio2
    ]
    
    static let payloadMap: [CXRadioPickerSelected: PayloadType] = [
        .radio1 : .link,
        .radio2 : .capture
    ]
    
    static let inversePayloadMap: [PayloadType: CXRadioPickerSelected] = [
        .link : .radio1,
        .capture : .radio2
    ]

    static let useMap: [CXRadioPickerSelected: TransmitType] = [
        .radio1: .orgProtocol,
        .radio2: .clipboard
    ]
    
    static let inverseUseMap: [TransmitType: CXRadioPickerSelected] = [
        .orgProtocol: .radio1,
        .clipboard: .radio2
    ]
    
    static let formatStringDB: [String: String] = [
        "label.title": "Format",
        "label.toolTip": "Choose output format",
        "radio1.title": "Org Mode",
        "radio1.toolTip": "Use Org Mode format",
        "radio2.title": "Markdown",
        "radio2.toolTip": "Use Markdown format",
    ]
    
    // TODO: add toolTip
    static let payloadStringDB: [String: String] = [
        "lable.title": "Payload",
        "radio1.title": "Link",
        "radio2.title": "Capture"
    ]
    
    // TODO: add toolTip
    static let useStringDB: [String: String] = [
        "label.title": "Use",
        "radio1.title": "Org Protocol",
        "radio2.title": "Clipboard"
    ]
    
    static func configurePickerUI(_ picker: CXRadioPicker, stringMap: [String: String]) {
        if let title = stringMap["label.title"] {
            picker.title = title
        }
        
        if let rTitle = stringMap["radio1.title"] {
            picker.radio1.title = rTitle
        }
        
        if let rTitle = stringMap["radio2.title"] {
            picker.radio2.title = rTitle
        }
        
        if let tooltip = stringMap["label.toolTip"] {
            picker.label.toolTip = tooltip
        }
        
        if let tooltip = stringMap["radio1.toolTip"] {
            picker.radio1.toolTip = tooltip
        }
        
        if let tooltip = stringMap["radio2.toolTip"] {
            picker.radio2.toolTip = tooltip
        }
    }
}
