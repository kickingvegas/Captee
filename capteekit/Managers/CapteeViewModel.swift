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

import Combine
import Cocoa

public class CapteeViewModel: ObservableObject {
    @Published public var urlString: String = ""
    @Published public var title: String = ""
    @Published public var body: AttributedString = AttributedString("")
    @Published public var template: String = ""
    @Published public var orgProtocol: OrgProtocolType = .storeLink
    @Published public var markupFormat: MarkupFormat = .orgMode
    @Published public var payloadType: PayloadType = .link
    @Published public var sendtoType: SendtoType = .orgProtocol
    @Published public var bodyDisabled: Bool = true
    @Published public var showSentToClipboardAlert = false
    @Published public var sendtoPickerDisabled: Bool = false
    @Published public var hideTemplate: Bool = true
    @Published public var hideBody: Bool = true
    @Published public var sendButtonDisabled: Bool = false
    @Published public var isURLValid: Bool = true
    @Published public var alertTitle = ""
    @Published public var alertMessage = ""
    
    public var capteeManager = CapteeManager()
    public var connectionManager = ConnectionManager()
    
    public init() {
        self.template = capteeManager.defaultTemplate
        
        if let url = URL(string: "org-protocol://capture/"),
           let _ = NSWorkspace.shared.urlForApplication(toOpen: url) {
            sendtoType = .orgProtocol
        } else {
            sendtoType = .clipboard
            sendtoPickerDisabled = true
        }

        if payloadType == .link {
            hideTemplate = true
            hideBody = true
        } else {
            hideBody = false
            switch markupFormat {
            case .orgMode:
                hideTemplate = false
            case .markdown:
                hideTemplate = true
            }
        }
        
        //evalEnableSendButton()
    }
    
    public func orgProtocolURL() -> URL? {
        capteeManager.orgProtcolURL(pType: orgProtocol,
                                    url: URL(string: urlString),
                                    title: title,
                                    body: body,
                                    template: template)
    }
    
    public func openURL(url: NSURL, with reply: @escaping (Bool) -> Void) {
        let service = connectionManager.xpcService()
        service.openURL(url: url, with: reply)
    }

    public func sendToClipboard(payload: String, with reply: @escaping (Bool) -> Void) {
        let service = connectionManager.xpcService()
        service.sendToClipboard(payload: payload, with: reply)
    }
    
    public func extractPayload() -> CapteePayload {
        CapteeUtils.extractPayloadContent(urlString: urlString,
                                          titleString: title,
                                          templateString: template,
                                          body: body)
    }
        
    
    public func captureAction(with reply: @escaping (Bool) -> Void) {
        var orgProtocolType: OrgProtocolType
        switch payloadType {
        case .link:
            orgProtocolType = .storeLink
        case .capture:
            orgProtocolType = .capture
        }
        
        let payload = extractPayload()

        switch markupFormat {
        case .orgMode:
            switch sendtoType {
            case .orgProtocol:
                if let url = capteeManager.orgProtcolURL(pType: orgProtocolType,
                                                         url: payload.url,
                                                         title: payload.title,
                                                         body: payload.body,
                                                         template: payload.template) {
                    if let appURL = NSWorkspace.shared.urlForApplication(toOpen: url) {
                        print("\(appURL.absoluteString)")
                        connectionManager.xpcService().openURL(url: url as NSURL, with: reply)
                    } else {
                        reply(false)
                    }
                }
            case .clipboard:
                if let message = capteeManager.orgMessage(payloadType: payloadType,
                                                          url: payload.url,
                                                          title: payload.title,
                                                          body: payload.body,
                                                          template: payload.template) {

                    connectionManager.xpcService().sendToClipboard(payload: message) { [weak self] result in
                        guard let self else { return }
                        
                        DispatchQueue.main.async {
                            self.alertTitle = "Sent to Clipboard"
                            self.alertMessage = self.shortenMessage(buf: message, length: 120)
                            self.showSentToClipboardAlert = true
                        }

                        reply(result)
                    }


                }
            }

        case .markdown:
            if let message = capteeManager.markdownMessage(payloadType: payloadType,
                                                           url: payload.url,
                                                           title: payload.title,
                                                           body: payload.body) {
                connectionManager.xpcService().sendToClipboard(payload: message) { [weak self] result in
                    guard let self else { return }
                    
                    DispatchQueue.main.async {
                        self.alertTitle = "Sent to Clipboard"
                        self.alertMessage = self.shortenMessage(buf: message, length: 120)
                        self.showSentToClipboardAlert = true
                    }
                    reply(result)
                }

            }
        }
    }
    
    public func evalEnableSendButton() {
        let payload = extractPayload()

        switch payloadType {
        case .link:
            sendButtonDisabled = !isURLValid
            
        case .capture:
            var bodyString: String?
            
            if let body = payload.body {
                bodyString = String(body.characters[...])
            }
            
            /*
             | url | title | template | body | sendDisabled |
             |-----+-------+----------+------+--------------|
             |   0 |     0 |        0 |    0 |            1 |
             |   0 |     0 |        1 |    0 |            1 |

             */

            sendButtonDisabled = (!isURLValid &&
                                  ((payload.title == nil) || (payload.title == "")) &&
                                  ((bodyString == nil) || (bodyString == "")))
        }
    }
    
    public func shortenMessage(buf: String, length: Int) -> String {
        var result: String = buf
        if buf.count > length {
            result = String(buf.prefix(length - 1)) + "…"
        }
        return result
    }
    
    public func synchronizePayload(_ payload: CapteePayload) {
        if let url = payload.url {
            urlString = url.absoluteString
        }
        
        if let title = payload.title {
            self.title = title
        }
        
        if let template = payload.template {
            self.template = template
        }
        
        if let body = payload.body {
            self.body = body
        }
    }
}
