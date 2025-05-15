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

import Combine
import Cocoa
import RegexBuilder

public enum CapteeError: Error {
    case invalidURLScheme
    case networkError(error: NSError)
    case titleNotFound
    case encodeStringToDataFailed
    case attributedStringCreationFailed(error: Error)
}

public class CapteeViewModel: ObservableObject {
    @Published public var urlString: String = "" {
        didSet {
            isURLValid = CapteeUtils.validateURL(string: urlString)
            sendButtonDisabled = !isSendButtonEnabled()
        }
    }
    @Published public var title: String = "" {
        didSet {
            sendButtonDisabled = !isSendButtonEnabled()
        }
    }
    @Published public var body: AttributedString = AttributedString("") {
        didSet {
            sendButtonDisabled = !isSendButtonEnabled()
        }
    }

    @Published public var template: String {
        didSet {
            capteeManager.persistedTemplateKey = template
        }
    }

    @Published public var markupFormat: MarkupFormat {
        didSet {
            capteeManager.persistedMarkupFormat = markupFormat
        }
    }

    @Published public var payloadType: PayloadType {
        didSet {
            capteeManager.persistedPayloadType = payloadType
            switch payloadType {
            case .link:
                orgProtocol = .storeLink
            case .capture:
                orgProtocol = .capture
            }
            sendButtonDisabled = !isSendButtonEnabled()
        }
    }

    @Published public var orgProtocol: OrgProtocolType

    @Published public var transmitType: TransmitType {
        didSet {
            capteeManager.persistedTransmitType = transmitType
        }
    }

    @Published public var showOnboardingAlert: Bool {
        didSet {
            capteeManager.persistedShowOnboardingAlert = showOnboardingAlert
        }
    }
    
    @Published public var stripFormatting: Bool {
        didSet {
            capteeManager.persistedStripFormatting = stripFormatting
        }
    }

    @Published public var isAlertRaised = false
    @Published public var isNetworkRequestInProgress = false
    @Published public var transmitPickerDisabled: Bool = false
    @Published public var sendButtonDisabled: Bool = true
    @Published public var isURLValid: Bool = true
    @Published public var isOrgProtocolSupported: Bool = false
    @Published public var alertTitle = ""
    @Published public var alertMessage = ""

    public var capteeManager = CapteeManager()
    public var connectionManager = ConnectionManager()

    public init() {
        orgProtocol = .storeLink
        template = capteeManager.persistedTemplateKey ?? "c"
        markupFormat = capteeManager.persistedMarkupFormat ?? .markdown
        payloadType = capteeManager.persistedPayloadType ?? .link
        transmitType = capteeManager.persistedTransmitType ?? .clipboard
        stripFormatting = capteeManager.persistedStripFormatting ?? false

        showOnboardingAlert = capteeManager.persistedShowOnboardingAlert ?? true
        if markupFormat == .markdown {
            transmitPickerDisabled = true
        }

        if let url = URL(string: "org-protocol://capture/"),
           let _ = NSWorkspace.shared.urlForApplication(toOpen: url) {
            isOrgProtocolSupported = true
        } else {
            isOrgProtocolSupported = false
            transmitType = .clipboard
            transmitPickerDisabled = true
        }
    }

    public func isTemplateHidden() -> Bool {
        switch payloadType {
        case .link:
            return true
        case .capture:
            switch markupFormat {
            case .orgMode:
                return false
            case .markdown:
                return true
            }
        }
    }

    public func isBodyHidden() -> Bool {
        switch payloadType {
        case .link:
            return true
        case .capture:
            return false
        }
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
        var body: AttributedString?
        
        if stripFormatting,
           let payloadBody = payload.body,
           payloadBody.characters.isEmpty == false {
            body = CapteeUtils.stripFormatting(buf: payloadBody)
        } else {
            body = payload.body
        }

        switch markupFormat {
        case .orgMode:
            switch transmitType {
            case .orgProtocol:
                if let url = capteeManager.orgProtcolURL(pType: orgProtocolType,
                                                         url: payload.url,
                                                         title: payload.title,
                                                         body: body,
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
                                                          body: body,
                                                          template: payload.template) {

                    connectionManager.xpcService().sendToClipboard(payload: message) { [weak self] result in
                        guard let self else { return }

                        DispatchQueue.main.async {
                            self.alertTitle = "Sent to Clipboard"
                            self.alertMessage = CapteeViewModel.truncate(buf: message, count: 120)
                            self.isAlertRaised = true
                        }
                        reply(result)
                    }
                }
            }

        case .markdown:
            if let message = capteeManager.markdownMessage(payloadType: payloadType,
                                                           url: payload.url,
                                                           title: payload.title,
                                                           body: body) {
                connectionManager.xpcService().sendToClipboard(payload: message) { [weak self] result in
                    guard let self else { return }

                    DispatchQueue.main.async {
                        self.alertTitle = "Sent to Clipboard"
                        self.alertMessage = CapteeViewModel.truncate(buf: message, count: 120)
                        self.isAlertRaised = true
                    }
                    reply(result)
                }

            }
        }
    }

    func isSendButtonEnabled() -> Bool {
        var result: Bool = false

        switch payloadType {
        case .link:
            result = (urlString == "") ? true : isURLValid
        case .capture:
            let bodyString = String(body.characters[...])

            if urlString == "" {
                // test if bodyString or title are populated
                result = (bodyString != "") || (title != "")
            } else {
                let urlIsValid = (urlString == "") ? true : CapteeUtils.validateURL(string: urlString)
                if urlIsValid {
                    result = (bodyString != "") || (title != "") || urlIsValid
                } else {
                    result = false
                }
            }
        }
        return result
    }

    /// Generate truncated string.
    /// - Parameters:
    ///   - buf: input string
    ///   - count: result string count
    /// - Returns: string of length specified by count
    public static func truncate(buf: String, count: Int) -> String {
        var result: String = buf
        if buf.count > count {
            result = String(buf.prefix(count - 1)) + "…"
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

    public func extractTitleFromURL(url: URL, closure: @escaping (Result<String, CapteeError>) -> Void) {
        let validSchemes = ["https"]

        guard let urlScheme = url.scheme else {
            closure(.failure(.invalidURLScheme))
            return
        }

        guard validSchemes.contains(urlScheme) else {
            closure(.failure(.invalidURLScheme))
            return
        }

        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error as? NSError {
                closure(.failure(.networkError(error: error)))
                return
            }

            if let data = data,
               let response = response as? HTTPURLResponse,
               200...299 ~= response.statusCode,
               let buf = String(data: data, encoding: .utf8),
               let newTitle = CapteeViewModel.extractTitleContent(buf) {

                DispatchQueue.main.async {
                    do {
                        let decodedString = try CapteeViewModel.decodeHTMLEntities(newTitle)
                        closure(.success(decodedString))
                    } catch {
                        closure(.failure(error as! CapteeError))
                    }
                }
            } else {
                closure(.failure(.titleNotFound))
            }
        }
        task.resume()
    }

    static func extractTitleContent(_ string: String) -> String? {
        var result: String?

        let pat = Regex {
            #"<title"#
            Optionally {
                OneOrMore {
                    CharacterClass.any
                }
            }
            #">"#
            Capture {
                OneOrMore {
                    CharacterClass.any
                }
            }
            #"</title>"#
        }

        let buf = string
            .replacingOccurrences(of: "<title", with: "<title", options: .caseInsensitive)
            .replacingOccurrences(of: "</title>", with: "</title>", options: .caseInsensitive)

        for line in buf.components(separatedBy: "\n") {
            if let match = line.firstMatch(of: pat) {
                result = String(match.1)
                break
            }
        }

        return result
    }


    static func decodeHTMLEntities(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw CapteeError.encodeStringToDataFailed
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        do {
            let attributedString = try NSAttributedString(data: data,
                                                          options: options,
                                                          documentAttributes: nil)
            return attributedString.string

        } catch {
            throw CapteeError.attributedStringCreationFailed(error: error)
        }
    }
}
