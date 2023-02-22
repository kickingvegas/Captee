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

// Modified from MacEditorv2 code by Marc Maset
// https://github.com/MarcMV/MacEditorTextView/blob/main/macEditorTextView.swift

import SwiftUI

struct CAPTextEditor: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    var theTextView = NSTextView.scrollableTextView()
    
    @Binding var text: NSAttributedString
    
    func makeNSView(context: Context) -> NSScrollView {
        let textView = (theTextView.documentView as! NSTextView)
        textView.isRichText = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isEditable = true
        textView.isFieldEditor = true
        textView.importsGraphics = true
        textView.usesRuler = true
        textView.usesInspectorBar = true
        textView.usesFontPanel = true

        textView.delegate = context.coordinator
        
        if let textStorage = textView.textStorage {
            textStorage.append(text)
        }

        return theTextView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
    }
}

extension CAPTextEditor {
    class Coordinator: NSObject, NSTextViewDelegate{
        
        var parent: CAPTextEditor
        var affectedCharRange: NSRange?
        
        init(_ parent: CAPTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            //Update text
            if let textStorage = textView.textStorage {
                self.parent.text = textStorage
            }
        }
        
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            return true
        }
    }
}
