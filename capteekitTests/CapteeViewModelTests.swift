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


import XCTest
@testable import CapteeKit

func randomURLString(scheme: String = "https") -> String {
    var bufList: [String] = []
    bufList.append(scheme)
    bufList.append("://")
    bufList.append(randomString(length: 10))
    bufList.append(".")
    bufList.append(randomString(length: 3))
    bufList.append("/")
    bufList.append(randomString(length: 10))
    
    return bufList.joined()
}

func randomCase(_ buf: String) -> String {
    var result: String = ""
    
    for (_, char) in buf.enumerated() {
        let test = Bool.random()
        if test {
            result.append(String(char.uppercased()))
        } else {
            result.append(String(char.lowercased()))
        }
    }
    
    return result
}

final class CapteeViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: "template")
        defaults.removeObject(forKey: "markup_format")
        defaults.removeObject(forKey: "payload_type")
        defaults.removeObject(forKey: "transmit_type")
        defaults.removeObject(forKey: "show_onboarding_alert")
    }
    
    override func tearDownWithError() throws {
    }
    
    func test_isTemplateHidden() throws {
        let viewModel = CapteeViewModel()
        
        viewModel.payloadType = .link
        XCTAssertTrue(viewModel.isTemplateHidden())
        
        viewModel.payloadType = .capture
        viewModel.markupFormat = .orgMode
        XCTAssertFalse(viewModel.isTemplateHidden())
        
        viewModel.markupFormat = .markdown
        XCTAssertTrue(viewModel.isTemplateHidden())
    }
    
    
    func test_isBodyHidden() throws {
        let viewModel = CapteeViewModel()
        
        viewModel.payloadType = .link
        XCTAssertTrue(viewModel.isBodyHidden())
        
        viewModel.payloadType = .capture
        XCTAssertFalse(viewModel.isBodyHidden())
    }
    
    
    func test_sendButtonDisabled() throws {
        let viewModel = CapteeViewModel()
        
        // Link
        viewModel.payloadType = .link
        
        viewModel.urlString = randomURLString()
        XCTAssertFalse(viewModel.sendButtonDisabled)
        
        viewModel.urlString = ""
        XCTAssertFalse(viewModel.sendButtonDisabled)
        
        viewModel.urlString = randomString(length: 33)
        XCTAssertTrue(viewModel.sendButtonDisabled)
        
        // Capture
        viewModel.payloadType = .capture
        
        viewModel.urlString = ""
        viewModel.title = randomString(length: 33)
        XCTAssertFalse(viewModel.sendButtonDisabled)
        
        viewModel.urlString = randomString(length: 33)
        viewModel.title = randomString(length: 33)
        XCTAssertTrue(viewModel.sendButtonDisabled)
        
        viewModel.urlString = ""
        viewModel.title = ""
        viewModel.body = AttributedString(randomString(length: 33))
        XCTAssertFalse(viewModel.sendButtonDisabled)
        
        viewModel.urlString = randomString(length: 33)
        viewModel.title = ""
        viewModel.body = AttributedString(randomString(length: 33))
        XCTAssertTrue(viewModel.sendButtonDisabled)
        
        viewModel.urlString = randomURLString()
        viewModel.title = randomString(length: 33)
        viewModel.body = AttributedString(randomString(length: 33))
        XCTAssertFalse(viewModel.sendButtonDisabled)
        
        viewModel.urlString = randomURLString()
        viewModel.title = ""
        viewModel.body = AttributedString("")
        XCTAssertFalse(viewModel.sendButtonDisabled)
        
        viewModel.urlString = randomString(length: 33)
        viewModel.title = randomString(length: 33)
        viewModel.body = AttributedString("")
        XCTAssertTrue(viewModel.sendButtonDisabled)
    }
    
    func test_truncate() throws {
        let buf = "hey there"
        let count = 3
        let result = CapteeViewModel.truncate(buf: buf, count: count)
        let control1 = "he…"
        XCTAssertEqual(result, control1)
        
        let control2 = buf
        let result2 = CapteeViewModel.truncate(buf: buf, count: 9)
        XCTAssertEqual(result2, control2)
    }
    
    func test_extractTitleContent() throws {
        var buf = ""
        var result: String?
        var content: String = ""
                
        result = CapteeViewModel.extractTitleContent(buf)
        XCTAssertNil(result)

        for _ in 1...100 {
            content = randomString(length: 30)
            buf = "\(randomCase("<title>"))\(content)\(randomCase("</title>"))"
            result = CapteeViewModel.extractTitleContent(buf)
            XCTAssertEqual(content, result)
        }
    }
    
    func test_decodeHTMLEntities() throws {
        var content: String
        var buf: String
        var control: String

        for _ in 1...100 {
            content = randomString(length: 30)
            buf = "&quot;\(content)&quot;"
            control = "\"\(content)\""
            do {
                let result = try CapteeViewModel.decodeHTMLEntities(buf)
                XCTAssertEqual(result, control)
            } catch {
                print("\(error)")
            }
        }
    }
    
    func test_firstRunCapteeManagerState() throws {
        let manager = CapteeManager()
        
        XCTAssertEqual(manager.persistedTemplateKey, "c")
        
        if let markupFormat = manager.persistedMarkupFormat {
            XCTAssertEqual(markupFormat, .markdown)
        }
        
        if let payloadType = manager.persistedPayloadType {
            XCTAssertEqual(payloadType, .link)
        }

        if let transmitType = manager.persistedTransmitType {
            XCTAssertEqual(transmitType, .clipboard)
        }
        
        if let showOnboardingAlert = manager.persistedShowOnboardingAlert {
            XCTAssertTrue(showOnboardingAlert)
        }
    }
    
    func test_firstRunViewModelState() throws {
        let viewModel = CapteeViewModel()
        
        XCTAssertEqual(viewModel.template, "c")
        XCTAssertEqual(viewModel.markupFormat, .markdown)
        XCTAssertEqual(viewModel.payloadType, .link)
        XCTAssertEqual(viewModel.transmitType, .clipboard)
        XCTAssertEqual(viewModel.showOnboardingAlert, true)
    }
    
    func test_viewModelWrites() throws {
        let viewModel = CapteeViewModel()
        let manager = viewModel.capteeManager
        
        viewModel.template = "i"
        XCTAssertEqual(viewModel.template, "i")
        XCTAssertEqual(manager.persistedTemplateKey, "i")
        
        viewModel.markupFormat = .orgMode
        XCTAssertEqual(viewModel.markupFormat, .orgMode)
        XCTAssertEqual(manager.persistedMarkupFormat, .orgMode)
        
        viewModel.payloadType = .capture
        XCTAssertEqual(viewModel.payloadType, .capture)
        XCTAssertEqual(manager.persistedPayloadType, .capture)

        viewModel.transmitType = .orgProtocol
        XCTAssertEqual(viewModel.transmitType, .orgProtocol)
        XCTAssertEqual(manager.persistedTransmitType, .orgProtocol)
        
        viewModel.showOnboardingAlert = false
        XCTAssertEqual(viewModel.showOnboardingAlert, false)
        XCTAssertEqual(manager.persistedShowOnboardingAlert, false)
    }
}
