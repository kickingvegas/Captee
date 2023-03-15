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

import SwiftUI
import CapteeKit

class CapteeObservableManager: ObservableObject {
    @Published var urlString: String = ""
    @Published var title: String = ""
    @Published var body: AttributedString = AttributedString("")
    @Published var template: String = ""
    @Published var orgProtocol: OrgProtocolType = .storeLink
    @Published var markupFormat: MarkupFormat = .orgMode
    @Published var payloadType: PayloadType = .link
    @Published var sendtoType: SendtoType = .orgProtocol
    @Published var bodyDisabled: Bool = true
    @Published var showSentToClipboardAlert = false
    @Published var sendtoPickerDisabled: Bool = false
    @Published var hideTemplate: Bool = true
    @Published var hideBody: Bool = true
    @Published var sendButtonDisabled: Bool = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    var capteeManager = CapteeManager()
    var connectionManager = ConnectionManager()
    
    init() {
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
        
        evalEnableSendButton()
    }
    
    func orgProtocolURL() -> URL? {
        capteeManager.orgProtcolURL(pType: orgProtocol,
                                    url: URL(string: urlString),
                                    title: title,
                                    body: body,
                                    template: template)
    }
    
    func openURL(url: NSURL, with reply: @escaping (Bool) -> Void) {
        let service = connectionManager.xpcService()
        service.openURL(url: url, with: reply)
    }

    func sendToClipboard(payload: String, with reply: @escaping (Bool) -> Void) {
        let service = connectionManager.xpcService()
        service.sendToClipboard(payload: payload, with: reply)
    }
    
    func extractPayload() -> CapteePayload {
        CapteeUtils.extractPayloadContent(urlString: urlString,
                                          titleString: title,
                                          templateString: template,
                                          body: body)
    }
        
    
    func captureAction(with reply: @escaping (Bool) -> Void) {
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
    
    func evalEnableSendButton() {
        let payload = extractPayload()
        
        switch payloadType {
        case .link:
            sendButtonDisabled = !(payload.url != nil)
            
        case .capture:
            sendButtonDisabled = !((payload.url != nil) || (payload.body != nil))
            
            if let body = payload.body {
                let bodyString = String(body.characters[...])
                sendButtonDisabled = sendButtonDisabled || (bodyString == "")
            }

        }

    }
    
    func shortenMessage(buf: String, length: Int) -> String {
        var result: String = buf
        if buf.count > length {
            result = String(buf.prefix(length - 1)) + "…"
        }
        return result
    }
}
