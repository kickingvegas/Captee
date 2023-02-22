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
    
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var bodyField: NSScrollView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var templateField: NSTextField!
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }

    override func loadView() {
        super.loadView()

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

    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        
        let urlString = self.urlField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleString = self.titleField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var templateString = self.templateField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if templateString == "" {
            templateString = "c"
        }
        
        capteeManager.defaultTemplate = templateString
        
        let bodyString: String? = self.textView.textStorage?.string
                
        var orgProtcolHost: OrgProtocolHost = .storeLink
        
        if bodyString != nil, bodyString != "" {
            orgProtcolHost = .capture
        }
        
        if let url = capteeManager.orgProtcolURL(host: orgProtcolHost,
                                                 url: URL(string: urlString),
                                                 title: titleString,
                                                 body: bodyString,
                                                 template: templateString) {
            print(url.absoluteString)
            NSWorkspace.shared.open(url)
        } else {
            // TODO: handle error
        }


        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
}

    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

}
