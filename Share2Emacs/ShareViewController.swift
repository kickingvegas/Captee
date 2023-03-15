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

class ShareViewController: NSViewController, NSTextFieldDelegate, NSTextViewDelegate {
    var capteeManager = CapteeManager()
    var connectionManager = ConnectionManager()
    
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var bodyField: NSScrollView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var templateField: NSTextField!
    @IBOutlet weak var templateLabel: NSTextField!
        
    @IBOutlet weak var formatOrgModeButton: NSButton!
    @IBOutlet weak var formatMarkdownButton: NSButton!
    @IBOutlet weak var payloadLinkButton: NSButton!
    @IBOutlet weak var payloadCaptureButton: NSButton!
    @IBOutlet weak var sendtoOrgProtocolButton: NSButton!
    @IBOutlet weak var sendtoClipboardButton: NSButton!
    
    
    var isOrgProtocolSupported = false {
        didSet {
            if isOrgProtocolSupported {
                sendtoClipboardButton.isEnabled = true
                sendtoOrgProtocolButton.isEnabled = true
                sendtoOrgProtocolButton.toolTip = "Use the org-protocol:// scheme."
            } else {
                sendtoClipboardButton.isEnabled = false
                sendtoOrgProtocolButton.isEnabled = false
                sendtoOrgProtocolButton.toolTip = "You do not have installed a version of Emacs that supports the org-protocol:// scheme."
            }
        }
    }
    
    var markupFormat: MarkupFormat = .orgMode {
        didSet {
            switch markupFormat {
            case .orgMode:
                // direct control
                formatOrgModeButton.state = .on
                
                if isOrgProtocolSupported {
                    sendtoOrgProtocolButton.isEnabled = true
                    sendtoClipboardButton.isEnabled = true
                }
                templateField.isEnabled = true
                templateField.isHidden = false
                templateLabel.isHidden = false
            case .markdown:
                // direct control
                formatMarkdownButton.state = .on
                
                sendtoClipboardButton.state = .on
                sendtoOrgProtocolButton.isEnabled = false
                sendtoClipboardButton.isEnabled = false
                sendtoType = .clipboard
                templateField.isEnabled = false
                templateField.isHidden = true
                templateLabel.isHidden = true
            }
            
        }
    }
    
    var payloadType: PayloadType = .link {
        didSet {
            switch payloadType {
            case .link:
                // direct control
                payloadLinkButton.state = .on
                
                orgProtocolType = .storeLink
                textView.isEditable = false
                templateField.isEnabled = false
                templateLabel.isHidden = true
                templateField.isHidden = true
            case .capture:
                // direct control
                payloadCaptureButton.state = .on
                
                orgProtocolType = .capture
                textView.isEditable = true
                if markupFormat == .orgMode {
                    templateField.isEnabled = true
                    templateField.isHidden = false
                    templateLabel.isHidden = false

                } else {
                    templateField.isEnabled = false
                    templateField.isHidden = true
                    templateLabel.isHidden = true
                }
            }
        }
    }
    
    var orgProtocolType: OrgProtocolType = .storeLink {
        didSet {}
    }
    var sendtoType: SendtoType = .orgProtocol {
        didSet {
            switch sendtoType {
            case .orgProtocol:
                sendtoOrgProtocolButton.state = .on
            case .clipboard:
                sendtoClipboardButton.state = .on
            }
        }
    }
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let extensionContext = self.extensionContext else {
            return
        }
        
        if let url = URL(string: "org-protocol://capture/"),
           let _ = NSWorkspace.shared.urlForApplication(toOpen: url) {
            isOrgProtocolSupported = true
            sendtoType = .orgProtocol
        } else {
            isOrgProtocolSupported = false
            sendtoType = .clipboard
            
        }
        
        
        // TODO: revisit initial state
        markupFormat = .orgMode
        
        if let item = extensionContext.inputItems.first as? NSExtensionItem,
           let contentText = item.attributedContentText {
            if let textStorage = self.textView.textStorage {
                textStorage.append(contentText)
            }
            payloadType = .capture
        } else {
            payloadType = .link
        }

        templateField.stringValue = capteeManager.defaultTemplate
        
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
                            }
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
                        })
                }
            }
        }
    }
    

    @IBAction func formatButtonAction(_ sender: Any) {
        let formatButton = sender as! NSButton
        if formatButton == formatOrgModeButton {
            markupFormat = .orgMode
        } else if formatButton == formatMarkdownButton {
            markupFormat = .markdown
        }
    }

    
    @IBAction func payloadButtonAction(_ sender: Any) {
        let payloadButton = sender as! NSButton
        if payloadButton == payloadLinkButton {
            payloadType = .link
        } else if payloadButton == payloadCaptureButton {
            payloadType = .capture
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


extension ShareViewController {
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        guard obj.object is NSTextField else {
            return
        }
        
        if let targetObject = obj.object {
            let textField = targetObject as! NSTextField
            
            if textField == urlField {
            } else if textField == titleField {
            } else if textField == templateField {
            }
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard obj.object is NSTextField else {
            return
        }
        
        if let targetObject = obj.object {
            let textField = targetObject as! NSTextField
            
            if textField == urlField {
            } else if textField == titleField {
            } else if textField == templateField {
                // TODO: persist field
            }
        }
    }
}
