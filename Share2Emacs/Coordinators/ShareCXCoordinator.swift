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
import Combine
import CapteeKit
import UniformTypeIdentifiers

class ShareCXCoordinator {
    
    var observableManager: CapteeViewModel
    
    var formatPicker: CXRadioPicker
    var payloadPicker: CXRadioPicker
    var usePicker: CXRadioPicker
    var urlField: NSTextField
    var titleField: NSTextField
    var templateField: NSTextField
    var templateLine: NSBox
    var textView: NSTextView
    var scrollableTextView: NSScrollView
    var textViewLine: NSBox

    private var formatPickerCancellable: AnyCancellable?
    private var payloadPickerCancellable: AnyCancellable?
    private var usePickerCancellable: AnyCancellable?
    private var sendButtonEnableCancellable: AnyCancellable?
    private var isURLValidCancellable: AnyCancellable?
    
    private var urlFieldValidator: CXURLFieldValidator
    private var titleFieldValidator: CXTitleFieldValidator
    private var templateFieldValidator: CXTemplateFieldValidator
    private var textViewValidator: CXTextViewValidator
    
    init(observableManager: CapteeViewModel,
         formatPicker: CXRadioPicker,
         payloadPicker: CXRadioPicker,
         usePicker: CXRadioPicker,
         urlField: NSTextField,
         titleField: NSTextField,
         templateField: NSTextField,
         templateLine: NSBox,
         textView: NSTextView,
         scrollableTextView: NSScrollView,
         textViewLine: NSBox,
         sendButton: NSButton) {
        
        
        self.observableManager = observableManager
        self.formatPicker = formatPicker
        self.payloadPicker = payloadPicker
        self.usePicker = usePicker
        self.urlField = urlField
        self.titleField = titleField
        self.templateField = templateField
        self.templateLine = templateLine
        self.textView = textView
        self.scrollableTextView = scrollableTextView
        self.textViewLine = textViewLine
        
        self.urlFieldValidator = CXURLFieldValidator(observableManager)
        self.titleFieldValidator = CXTitleFieldValidator(observableManager)
        self.templateFieldValidator = CXTemplateFieldValidator()
        self.textViewValidator = CXTextViewValidator(observableManager)
        
        urlField.delegate = urlFieldValidator
        titleField.delegate = titleFieldValidator
        templateField.delegate = templateFieldValidator
        textView.delegate = textViewValidator

        formatPickerCancellable = formatPicker.$selection.sink { [weak self] selection in
            guard let self else { return }
            guard let selection = selection else { return }
            
            if let markupFormat = CXRadioPickerMaps.formatMap[selection] {
                self.observableManager.markupFormat = markupFormat
                
                switch markupFormat {
                case .markdown:
                    self.observableManager.sendtoType = .clipboard
                    // choose clipboard
                    if let useSelection = CXRadioPickerMaps.inverseUseMap[.clipboard] {
                        self.usePicker.selection = useSelection
                    }
                    
                    self.usePicker.isEnabled = false
                    self.templateField.isHidden = true
                    self.templateLine.isHidden = true

                case .orgMode:
                    self.usePicker.isEnabled = true
                    
                    switch self.observableManager.payloadType {
                    case .link:
                        self.templateField.isHidden = true
                        self.templateLine.isHidden = true
                        
                    case .capture:
                        self.templateField.isHidden = false
                        self.templateLine.isHidden = false
                    }
                }
            }
        }
        
        payloadPickerCancellable = payloadPicker.$selection.sink { [weak self] selection in
            guard let self else { return }
            guard let selection = selection else { return }
            
            if let payloadType = CXRadioPickerMaps.payloadMap[selection] {
                self.observableManager.payloadType = payloadType
                
                switch payloadType {
                case .link:
                    self.observableManager.orgProtocol = .storeLink
                    self.templateLine.isHidden = true
                    self.templateField.isHidden = true
                    self.scrollableTextView.isHidden = true
                    self.textViewLine.isHidden = true
                    
                case .capture:
                    self.observableManager.orgProtocol = .capture
                    if self.observableManager.markupFormat == .markdown {
                        self.templateLine.isHidden = true
                        self.templateField.isHidden = true
                    } else {
                        self.templateLine.isHidden = false
                        self.templateField.isHidden = false
                    }
                    self.scrollableTextView.isHidden = false
                    self.textViewLine.isHidden = false
                }
            }
        }
        
        usePickerCancellable = usePicker.$selection.sink { [weak self] selection in
            guard let self else { return }
            guard let selection = selection else { return }
            
            if let sendtoType = CXRadioPickerMaps.useMap[selection] {
                self.observableManager.sendtoType = sendtoType
            }
        }
        
        sendButtonEnableCancellable = observableManager.$sendButtonDisabled.sink { sendButtonDisabled in
            sendButton.isEnabled = !sendButtonDisabled
        }
        
        isURLValidCancellable = observableManager.$isURLValid.sink { [weak self] isURLValid in
            guard let self else { return }
            
            if isURLValid {
                self.urlField.textColor = NSColor.labelColor
            } else {
                self.urlField.textColor = .red
            }
        }

    }
    
    
    func synchronizeObservableManagerWithUI() {
        let payload = Share2EmacsUtils.extractPayloadContentFromAppKit(urlField: urlField,
                                                                       titleField: titleField,
                                                                       templateField: templateField,
                                                                       textView: textView)
        
        observableManager.synchronizePayload(payload)
        
    }
    
    
    func configureTextStorage(extensionContext: NSExtensionContext) {
        if let item = extensionContext.inputItems.first as? NSExtensionItem,
           let contentText = item.attributedContentText {
            if let textStorage = self.textView.textStorage {
                textStorage.append(contentText)
            }
            payloadPicker.selection = CXRadioPickerMaps.inversePayloadMap[.capture]
        } else {
            payloadPicker.selection = CXRadioPickerMaps.inversePayloadMap[.link]
        }
    }
    
    func configureTemplateField() {
        templateField.stringValue = observableManager.capteeManager.defaultTemplate
        observableManager.template = observableManager.capteeManager.defaultTemplate
    }
    
    func configureLinkFields(extensionContext: NSExtensionContext) {
        if let item = extensionContext.inputItems.first as? NSExtensionItem,
           let attachments = item.attachments {
            for itemProvider in attachments {
                if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.url.identifier) { [weak self] data, error in
                        guard let self else { return }
                        if let data = data {
                            let buf = String(decoding: data, as: UTF8.self)
                            if let url = URL(string: buf) {
                                self.urlField.stringValue = url.absoluteString
                                self.observableManager.urlString = url.absoluteString
                                self.observableManager.isURLValid = true
                            }
                            
                            self.observableManager.evalEnableSendButton()
                        }
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.propertyList.identifier) {
                    itemProvider.loadItem(
                        forTypeIdentifier: UTType.propertyList.identifier,
                        options: nil,
                        completionHandler: { [weak self] (item, error) -> Void in
                            guard let self else { return }
                            
                            guard let dictionary = item as? NSDictionary,
                                  let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                                  let title = results["title"] as? String,
                                  let _ = results["href"] as? String else {
                                return
                            }
                            
                            //print("title: \(title)")
                            //print("href: \(href)")
                            self.titleField.stringValue = title
                            self.observableManager.title = title
                        })
                }
            }
        }
    }
    
    
    func send() {
        let payload = Share2EmacsUtils.extractPayloadContentFromAppKit(urlField: urlField,
                                                                       titleField: titleField,
                                                                       templateField: templateField,
                                                                       textView: textView)
        
        let markupFormat = observableManager.markupFormat
        let sendtoType = observableManager.sendtoType
        let orgProtocolType = observableManager.orgProtocol
        let payloadType = observableManager.payloadType
        let capteeManager = observableManager.capteeManager
        let connectionManager = observableManager.connectionManager
        
        switch markupFormat {
        case .orgMode:
            switch sendtoType {
            case .orgProtocol:
                if let url = capteeManager.orgProtcolURL(pType: orgProtocolType,
                                                         url: payload.url,
                                                         title: payload.title,
                                                         body: payload.body,
                                                         template: payload.template) {
                    connectionManager.xpcService().openURL(url: url as NSURL) { result in
                        print("\(result)")
                    }
                }
            case .clipboard:
                if let message = capteeManager.orgMessage(payloadType: payloadType,
                                                          url: payload.url,
                                                          title: payload.title,
                                                          body: payload.body,
                                                          template: payload.template) {
                    connectionManager.xpcService().sendToClipboard(payload: message) { result in
                        print("\(result)")
                    }
                }
            }

        case .markdown:
            if let message = capteeManager.markdownMessage(payloadType: payloadType,
                                                           url: payload.url,
                                                           title: payload.title,
                                                           body: payload.body) {
                connectionManager.xpcService().sendToClipboard(payload: message) { result in
                    print("\(result)")
                }
            }
        }

    }
}
