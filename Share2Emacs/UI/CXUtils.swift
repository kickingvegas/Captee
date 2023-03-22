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

import AppKit

public struct CXUtils {
    
    public static func newLabel(string: String = "",
                                font: NSFont = NSFont.systemFont(ofSize: 12),
                                alignment: NSTextAlignment = .left) -> NSTextField {
        let label = NSTextField(string: string)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isBezeled = false
        label.isEditable = false
        label.drawsBackground = false
        label.isBordered = false
        label.isSelectable = false
        label.font = font
        label.alignment = alignment

        return label
    }
    
    public static func newTextField(string: String = "",
                                    placeholder: String = "",
                                    font: NSFont = NSFont.systemFont(ofSize: 12),
                                    alignment: NSTextAlignment = .left,
                                    toolTip: String = "") -> NSTextField {
        let textField = NSTextField(string: string)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isBezeled = false
        textField.isEditable = true
        textField.drawsBackground = false
        textField.placeholderString = placeholder
        textField.isBordered = false
        textField.toolTip = toolTip
        textField.font = font
        return textField
    }
    
    public static func separator() -> NSBox {
        let result = NSBox()
        result.boxType = .separator
        return result
    }
    
    
    public static func newHStack(spacing: CGFloat = 5) -> NSStackView {
        newStackView(orientation: .horizontal, spacing: spacing)
    }
    
    public static func newVStack(spacing: CGFloat = 5) -> NSStackView {
        newStackView(orientation: .vertical, spacing: spacing)
    }
    
    public static func newStackView(orientation: NSUserInterfaceLayoutOrientation,
                                    spacing: CGFloat = 5) -> NSStackView {
        let result = NSStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.orientation = orientation
        result.spacing = spacing
        return result
    }
    
    
    public static func newButton(title: String = "Some Button",
                                 bezelStyle: NSButton.BezelStyle = .rounded,
                                 buttonType: NSButton.ButtonType = .momentaryPushIn,
                                 target: AnyObject?,
                                 action: Selector?) -> NSButton {
        let result = NSButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.title = title
        result.target = target
        result.action = action
        result.setButtonType(.momentaryPushIn)
        result.bezelStyle = bezelStyle
        return result
    }


    
}
