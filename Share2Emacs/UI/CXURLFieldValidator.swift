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


import Cocoa
import CapteeKit

class CXURLFieldValidator: NSObject, NSTextFieldDelegate {
    let observableManager: CapteeViewModel
    
    init(_ observableManager: CapteeViewModel) {
        self.observableManager = observableManager
    }
    
//    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
//        print("should end url editing \(fieldEditor.string)")
//        return true
//    }
//
//    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
//        print("should begin url editing \(fieldEditor.string)")
//        return true
//    }
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        guard obj.object is NSTextField else {
            return
        }
        
        if let targetObject = obj.object {
            let textField = targetObject as! NSTextField
            // TODO: comment out
            print("did begin url editing: \(textField.stringValue)")
        }

    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard obj.object is NSTextField else {
            return
        }
        if let targetObject = obj.object {
            let textField = targetObject as! NSTextField
            // TODO: comment out
            print("did change url editing: \(textField.stringValue)")
            observableManager.urlString = textField.stringValue
            observableManager.isURLValid = CapteeUtils.validateURL(string: textField.stringValue)
            observableManager.evalEnableSendButton()
        }

    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard obj.object is NSTextField else {
            return
        }
        
        if let targetObject = obj.object {
            let textField = targetObject as! NSTextField
            // TODO: comment out
            print("did end url editing: \(textField.stringValue)")
            observableManager.urlString = textField.stringValue
            observableManager.isURLValid = CapteeUtils.validateURL(string: textField.stringValue)
            observableManager.evalEnableSendButton()
        }
    }
}