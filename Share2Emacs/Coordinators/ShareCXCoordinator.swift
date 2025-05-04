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
import Combine
import CapteeKit
import UniformTypeIdentifiers
import RegexBuilder

class ShareCXCoordinator {

    var viewModel: CapteeViewModel

    var formatPicker: CXRadioPicker
    var payloadPicker: CXRadioPicker
    var transmitPicker: CXRadioPicker
    var urlField: NSTextField
    var titleField: NSTextField
    var templateField: NSTextField
    var templateLine: NSBox
    var textView: NSTextView
    var scrollableTextView: NSScrollView
    var textViewLine: NSBox
    var sendButton: NSButton
    var progressIndicator: NSProgressIndicator

    private var formatPickerCancellable: AnyCancellable?
    private var payloadPickerCancellable: AnyCancellable?
    private var transmitPickerCancellable: AnyCancellable?
    private var sendButtonEnableCancellable: AnyCancellable?
    private var isURLValidCancellable: AnyCancellable?
    private var isTransmitPickerDisabledCancellable: AnyCancellable?

    private var urlFieldValidator: CXURLFieldValidator
    private var titleFieldValidator: CXTitleFieldValidator
    private var templateFieldValidator: CXTemplateFieldValidator
    private var textViewValidator: CXTextViewValidator

    init(viewModel: CapteeViewModel,
         formatPicker: CXRadioPicker,
         payloadPicker: CXRadioPicker,
         transmitPicker: CXRadioPicker,
         urlField: NSTextField,
         titleField: NSTextField,
         templateField: NSTextField,
         templateLine: NSBox,
         textView: NSTextView,
         scrollableTextView: NSScrollView,
         textViewLine: NSBox,
         sendButton: NSButton,
         progressIndicator: NSProgressIndicator) {

        self.viewModel = viewModel
        self.formatPicker = formatPicker
        self.payloadPicker = payloadPicker
        self.transmitPicker = transmitPicker
        self.urlField = urlField
        self.titleField = titleField
        self.templateField = templateField
        self.templateLine = templateLine
        self.textView = textView
        self.scrollableTextView = scrollableTextView
        self.textViewLine = textViewLine
        self.sendButton = sendButton
        self.progressIndicator = progressIndicator

        self.urlFieldValidator = CXURLFieldValidator(viewModel)
        self.titleFieldValidator = CXTitleFieldValidator(viewModel)
        self.templateFieldValidator = CXTemplateFieldValidator(viewModel)
        self.textViewValidator = CXTextViewValidator(viewModel)

        urlField.delegate = urlFieldValidator
        titleField.delegate = titleFieldValidator
        templateField.delegate = templateFieldValidator
        textView.delegate = textViewValidator

        formatPicker.selection = CXRadioPickerMaps.inverseFormatMap[viewModel.markupFormat]
        payloadPicker.selection = CXRadioPickerMaps.inversePayloadMap[viewModel.payloadType]
        transmitPicker.selection = CXRadioPickerMaps.inverseUseMap[viewModel.transmitType]
    }


    func initCancellables() {
        formatPickerCancellable = formatPicker.$selection.sink { [weak self] selection in
            guard let self else { return }
            guard let selection = selection else { return }

            if let markupFormat = CXRadioPickerMaps.formatMap[selection] {
                self.viewModel.markupFormat = markupFormat

                switch markupFormat {
                case .markdown:
                    self.viewModel.transmitType = .clipboard
                    // choose clipboard
                    if let useSelection = CXRadioPickerMaps.inverseUseMap[.clipboard] {
                        self.transmitPicker.selection = useSelection
                    }

                    self.viewModel.transmitPickerDisabled = true
                    self.templateField.isHidden = true
                    self.templateLine.isHidden = true

                case .orgMode:
                    if self.viewModel.isOrgProtocolSupported {
                        self.viewModel.transmitPickerDisabled = false
                    }

                    switch self.viewModel.payloadType {
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
                self.viewModel.payloadType = payloadType

                self.templateLine.isHidden = self.viewModel.isTemplateHidden()
                self.templateField.isHidden = self.viewModel.isTemplateHidden()
                self.scrollableTextView.isHidden = self.viewModel.isBodyHidden()
            }
        }

        transmitPickerCancellable = transmitPicker.$selection.sink { [weak self] selection in
            guard let self else { return }
            guard let selection = selection else { return }

            if let transmitType = CXRadioPickerMaps.useMap[selection] {
                self.viewModel.transmitType = transmitType
            }
        }

        sendButtonEnableCancellable = viewModel.$sendButtonDisabled.sink { [weak self] sendButtonDisabled in
            guard let self else { return }
            self.sendButton.isEnabled = !sendButtonDisabled
        }

        isURLValidCancellable = viewModel.$isURLValid.sink { [weak self] isURLValid in
            guard let self else { return }

            if isURLValid {
                self.urlField.textColor = NSColor.labelColor
            } else {
                self.urlField.textColor = .red
            }
        }

        isTransmitPickerDisabledCancellable = viewModel.$transmitPickerDisabled.sink { [weak self] transmitPickerDisabled in
            guard let self else { return }
            self.transmitPicker.isEnabled = !transmitPickerDisabled
            if !self.viewModel.isOrgProtocolSupported {
              self.transmitPicker.selection = CXRadioPickerMaps.inverseUseMap[.clipboard]
            }
        }


    }

    func synchronizeObservableManagerWithUI() {
        let payload = Share2EmacsUtils.extractPayloadContentFromAppKit(urlField: urlField,
                                                                       titleField: titleField,
                                                                       templateField: templateField,
                                                                       textView: textView)

        viewModel.synchronizePayload(payload)
    }


    func configureTextStorage(extensionContext: NSExtensionContext) {
        if let item = extensionContext.inputItems.first as? NSExtensionItem,
           let contentText = item.attributedContentText {
            if let textStorage = self.textView.textStorage {
                // Coerce foreground and background text color to conform to system appearance
                let newContentText = NSMutableAttributedString(attributedString: contentText)
                newContentText.addAttribute(.foregroundColor,
                                            value: NSColor.textColor,
                                            range: NSMakeRange(0, contentText.string.count))

                newContentText.addAttribute(.backgroundColor,
                                            value: NSColor.textBackgroundColor,
                                            range: NSMakeRange(0, contentText.string.count))

                //print ("contentText: \(newContentText)")
                textStorage.append(newContentText)

                do {
                    let body = try AttributedString(textStorage, including: \.appKit)
                    viewModel.body = body
                } catch {
                    // TODO: need to handle properly
                    print("ERROR: nothing in text storage: configureTextStorage")
                }

            }
            payloadPicker.selection = CXRadioPickerMaps.inversePayloadMap[.capture]
        }
    }

    func configureTemplateField() {
        if let templateKey = viewModel.capteeManager.persistedTemplateKey {
            templateField.stringValue = templateKey
            viewModel.template = templateKey
        }
    }

    func configureLinkFields(extensionContext: NSExtensionContext) {
        if let item = extensionContext.inputItems.first as? NSExtensionItem,
           let attachments = item.attachments {

            let group = DispatchGroup()
            for itemProvider in attachments {
                if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.url.identifier) { [weak self] data, error in
                        guard let self else { return }
                        if let data = data {
                            let buf = String(decoding: data, as: UTF8.self)
                            if let url = URL(string: buf) {
                                self.urlField.stringValue = url.absoluteString
                                self.viewModel.urlString = url.absoluteString
                                self.viewModel.isURLValid = true
                            }
                        }
                        group.leave()
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.propertyList.identifier) {
                    group.enter()
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
                            self.viewModel.title = title
                            group.leave()
                        })
                }
            }
            group.notify(queue: .main) { [weak self] in
                guard let self else { return }
                let title = self.viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines)

                if let url = URL(string: self.viewModel.urlString),
                   title == "" {

                    self.titleField.isEnabled = false
                    self.progressIndicator.isHidden = false
                    self.progressIndicator.startAnimation(self.progressIndicator)

                    self.viewModel.extractTitleFromURL(url: url) { [weak self] result in
                        guard let self else { return }

                        switch result {
                        case .success(let extractedTitle):
                            DispatchQueue.main.async { [weak self] in
                                guard let self else { return }
                                self.titleField.stringValue = extractedTitle
                                self.viewModel.title = extractedTitle

                            }

                        case .failure(_):
                            DispatchQueue.main.async { [weak self] in
                                guard let self else { return }
                                self.titleField.isEnabled = true
                            }
                        }

                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            self.titleField.isEnabled = true
                            self.progressIndicator.stopAnimation(self.progressIndicator)
                            self.progressIndicator.isHidden = true
                        }
                    }

                }
            }
        }
    }


    func send() {
        let payload = Share2EmacsUtils.extractPayloadContentFromAppKit(urlField: urlField,
                                                                       titleField: titleField,
                                                                       templateField: templateField,
                                                                       textView: textView)

        let markupFormat = viewModel.markupFormat
        let transmitType = viewModel.transmitType
        let orgProtocolType = viewModel.orgProtocol
        let payloadType = viewModel.payloadType
        let capteeManager = viewModel.capteeManager
        let connectionManager = viewModel.connectionManager

        switch markupFormat {
        case .orgMode:
            switch transmitType {
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
