//
//  ShareViewController.swift
//  Share2Emacs
//
//  Created by Charles Choi on 2/14/23.
//

import Cocoa
import UniformTypeIdentifiers

class ShareViewController: NSViewController {
    
    var capturedURL: URL?
    var contentText: NSAttributedString?
    var capturedTitle: String?
    
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
        
        if let userInfo = item.userInfo as? [String: Any],
           let data = userInfo[NSExtensionItemAttributedContentTextKey] as? Data {
            let payload = String(decoding: data, as: UTF8.self)
            print("AYE!: \(payload)")
            
        }
        
//        if let userInfo = item.userInfo {
//            print("\(userInfo)")
//
//            for k in userInfo.keys {
//                if userInfo[k] is NSArray {
//                    continue
//                }
//
//                let x = userInfo[k] as! Data
//                //print("\(x)")
//                let payload = String(decoding: x, as: UTF8.self)
//                print("FUCK: \(payload)")
//            }
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
        
        if let attachments = item.attachments {
            NSLog("Attachments = %@", attachments as NSArray)
            for itemProvider in attachments {
                if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.url.identifier) { [weak self] data, error in
                        if let data = data {
                            let buf = String(decoding: data, as: UTF8.self)
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

                            print("title: \(title)")
                            self?.capturedTitle = title
                            print("href: \(href)")
                            self?.titleField.stringValue = title
                        })
                }
            }
        } else {
            NSLog("No Attachments")
        }
    }

    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()

        var orgProtocolComponents = URLComponents()
        orgProtocolComponents.scheme = "org-protocol"
        var queryItems = [URLQueryItem]()
        
        let urlString = self.urlField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString != "" {
            queryItems.append(URLQueryItem(name: "url", value: urlString))
        }
        
        let titleString = self.titleField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if titleString != "" {
            queryItems.append(URLQueryItem(name: "title", value: titleString))
        }
        
        var templateString = self.templateField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if templateString == "" {
            templateString = "c"
        }
        
        queryItems.append(URLQueryItem(name: "template", value: templateString))

        if self.capturedURL != nil {
            orgProtocolComponents.host = "store-link"
        } else {
            orgProtocolComponents.host = "capture"
            
            if let bodyString = self.textView.textStorage?.string {
                queryItems.append(URLQueryItem(name: "body", value: bodyString))
            }
        }
        
        
        orgProtocolComponents.queryItems = queryItems
        
//
//
//        if let contentText = self.contentText {
//
//            orgProtocolComponents.host = "capture"
//
//            var title = ""
//            if contentText.string.count > 10 {
//                title = String(self.titleField.stringValue)
//            } else {
//                title = contentText.string
//            }
//
//            orgProtocolComponents.queryItems = [
//                URLQueryItem(name: "template", value: "c"),
//                URLQueryItem(name: "title", value: title),
//                URLQueryItem(name: "body", value: contentText.string)
//            ]
//        }
        
        if let url = orgProtocolComponents.url  {
            print(url.absoluteString)
            NSWorkspace.shared.open(url)
        }

        
        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
}

    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

}
