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
import UniformTypeIdentifiers
import CapteeKit

class ShareViewController: NSViewController {
    
    var capturedURL: URL?
    var contentText: NSAttributedString?
    var capturedTitle: String?
    
    var capteeManager = CapteeManager()
    var connectionManager = ConnectionManager()
    
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var bodyField: NSScrollView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var templateField: NSTextField!
        
    @IBOutlet weak var formatOrgModeButton: NSButton!
    @IBOutlet weak var formatMarkdownButton: NSButton!
    @IBOutlet weak var payloadLinkButton: NSButton!
    @IBOutlet weak var payloadCaptureButton: NSButton!
    @IBOutlet weak var sendtoOrgProtocolButton: NSButton!
    @IBOutlet weak var sendtoClipboardButton: NSButton!
    
    var markupFormat: MarkupFormat = .orgMode {
        didSet {}
    }
    var payloadType: PayloadType = .link {
        didSet {}
    }
    var orgProtocolType: OrgProtocolType = .storeLink {
        didSet {}
    }
    var sendtoType: SendtoType = .orgProtocol {
        didSet {}
    }
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    override func loadView() {
        super.loadView()
        
        self.formatOrgModeButton.state = .on
        self.payloadLinkButton.state = .on
        self.sendtoOrgProtocolButton.state = .on

        formatButtonAction(formatOrgModeButton as Any)
        payloadButtonAction(payloadLinkButton as Any)
        sendtoButtonAction(sendtoOrgProtocolButton as Any)
        
        textView.isEditable = false

        // Insert code here to customize the view
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        
//        if let userInfo = item.userInfo as? [String: Any],
//           let data = userInfo[NSExtensionItemAttributedContentTextKey] as? Data {
//            let payload = String(decoding: data, as: UTF8.self)
//            print("AYE!: \(payload)")
//
//        }

            
        if let contentText = item.attributedContentText {
            print("\(contentText.string)")
            self.contentText = contentText
            print("\(contentText)\n\(contentText.attributeKeys)")
            if let textStorage = self.textView.textStorage {
                textStorage.append(contentText)
                payloadCaptureButton.state = .on
                payloadButtonAction(payloadCaptureButton as Any)
            }
        }
        
        self.templateField.stringValue = capteeManager.defaultTemplate
        
                
        if let attachments = item.attachments {
            NSLog("Attachments = %@", attachments as NSArray)
            for itemProvider in attachments {
                if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.url.identifier) { [weak self] data, error in
                        if let data = data {
                            let buf = String(decoding: data, as: UTF8.self)
                            // TODO: amend
                            NSLog("URL: %@", buf)
                            
                            self?.capturedURL = URL(string: buf)
                            if let url = self?.capturedURL {
                                self?.urlField.stringValue = url.absoluteString
                            }
                        }
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.propertyList.identifier) {
                    itemProvider.loadItem(
                        forTypeIdentifier: UTType.propertyList.identifier,
                        options: nil,
                        completionHandler: { [weak self] (item, error) -> Void in

                            guard let dictionary = item as? NSDictionary,
                                  let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                                  let title = results["title"] as? String,
                                  let href = results["href"] as? String else {
                                return
                            }

                            // TODO: amend
                            print("title: \(title)")
                            self?.capturedTitle = title
                            // TODO: amend
                            print("href: \(href)")
                            self?.titleField.stringValue = title
                        })
                }
            }
        } else {
            // TODO: amend
            NSLog("No Attachments")
        }
    }

    @IBAction func formatButtonAction(_ sender: Any) {
        let formatButton = sender as! NSButton
        if formatButton == formatOrgModeButton {
            markupFormat = .orgMode
            sendtoOrgProtocolButton.state = .on
            sendtoOrgProtocolButton.isEnabled = true
            sendtoClipboardButton.isEnabled = true
        } else if formatButton == formatMarkdownButton {
            markupFormat = .markdown
            sendtoClipboardButton.state = .on
            sendtoOrgProtocolButton.isEnabled = false
            sendtoClipboardButton.isEnabled = false
            sendtoType = .clipboard
        }

    }
    
    @IBAction func payloadButtonAction(_ sender: Any) {
        let payloadButton = sender as! NSButton
        if payloadButton == payloadLinkButton {
            payloadType = .link
            orgProtocolType = .storeLink
            textView.isEditable = false
        } else if payloadButton == payloadCaptureButton {
            payloadType = .capture
            orgProtocolType = .capture
            textView.isEditable = true
        }
    }
    
    @IBAction func sendtoButtonAction(_ sender: Any) {
        let sendtoButton = sender as! NSButton
        if sendtoButton == sendtoOrgProtocolButton {
            sendtoType = .orgProtocol
        } else if sendtoButton == sendtoClipboardButton {
            sendtoType = .clipboard
        }
    }
    
    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        
        let payload = Share2EmacsUtils.extractPayloadContentFromAppKit(urlField: urlField,
                                                                       titleField: titleField,
                                                                       templateField: templateField,
                                                                       textView: textView)
        
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

        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
    }
    
    

    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

}

