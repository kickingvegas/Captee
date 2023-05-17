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
import RegexBuilder
@testable import CapteeKit

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

func randomSentence(words: Int) -> String {
    var sentence = [String]()
    for _ in 1...words {
        sentence.append(randomString(length: Int.random(in: 1..<10)))
    }
    
    let result = sentence.joined(separator: " ")
    return result
}

func randomURL(scheme: String = "https",
               host: String = randomString(length: 10) + "." + randomString(length: 3),
               path: String = "/" + randomString(length: 30)) -> URL? {
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.path = path
    
    var queryItems = [URLQueryItem]()
    
    for _ in 1...3 {
        queryItems.append(URLQueryItem(name: randomString(length: 5), value: randomString(length: 5)))
    }
    urlComponents.queryItems = queryItems
    
    return urlComponents.url
}

final class CapteeKitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    fileprivate func orgProtocolURL_testbench(pType: OrgProtocolType, url: URL?, title:String?, body: AttributedString?, template: String?) {
        let capteeManager = CapteeManager()
        var urlString = ""
        if let url = url {
            urlString = url.absoluteString
        }
        
        var bodyString = ""
        if let body = body {
            bodyString = String(body.characters[...])
        }
        
        if let url = capteeManager.orgProtcolURL(pType: pType,
                                                 url: url,
                                                 title: title,
                                                 body: body,
                                                 template: template) {
            if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                XCTAssertTrue(urlComponents.scheme == "org-protocol")
                XCTAssertTrue(urlComponents.host == pType.rawValue)
                
                if let queryItems = urlComponents.queryItems {
                    //print("\(queryItems)")
                    for item in queryItems {
                        if item.name == "title" {
                            XCTAssertTrue(item.value == title)
                        } else if item.name == "url" {
                            XCTAssertTrue(item.value == urlString)
                        } else if item.name == "body" {
                            XCTAssertTrue(item.value == bodyString)
                        } else if item.name == "template" {
                            XCTAssertTrue(item.value == template)
                        }
                    }
                }
                //print("\(url.absoluteString)")
            }
        }
    }

    
    fileprivate func verifyOrgLinkMarkup(_ link: String, _ url: URL, _ title: String) {
        //print("\(orgLink)")
        
        let pat = Regex {
            #"[["#
            Capture {
                OneOrMore {
                    CharacterClass.any
                }
            }
            #"]["#
            Capture {
                NegativeLookahead {
                    #"]"#
                }
                OneOrMore {
                    CharacterClass.any
                }
            }
            #"]]"#
        }
        
        if let match = link.firstMatch(of: pat) {
            //print(match.0)
            //print(match.1)
            //print(match.2)
            
            let testUrlString = String(match.1)
            let testTitleString = String(match.2)
            
            XCTAssertEqual(url.absoluteString, testUrlString)
            XCTAssertEqual(title, testTitleString)
        } else {
            XCTAssert(false, "failed to match org link pattern \(link)")
        }
    }
    

    
    fileprivate func verifyMarkdownLinkMarkup(_ link: String, _ url: URL, _ title: String) {
        let pat = Regex {
            #"["#
            Capture {
                OneOrMore {
                    CharacterClass.any
                }
            }
            #"]("#
            Capture {
                NegativeLookahead {
                    #")"#
                }
                OneOrMore {
                    CharacterClass.any
                }
            }
            #")"#
        }
        
        if let match = link.firstMatch(of: pat) {
            //print(match.0)
            //print(match.1)
            //print(match.2)
            
            let testUrlString = String(match.2)
            let testTitleString = String(match.1)
            
            XCTAssertEqual(url.absoluteString, testUrlString)
            XCTAssertEqual(title, testTitleString)
        } else {
            XCTAssert(false, "failed to match markdown link pattern \(link)")
        }
    }
    

    
}


extension CapteeKitTests {
    
    func test_orgProtocolURL_capture() throws {
        if let url = randomURL() {
            let body = AttributedString(randomSentence(words: 5))
            
            orgProtocolURL_testbench(pType: .capture,
                                     url: url,
                                     title: randomSentence(words: 5),
                                     body: body,
                                     template: randomString(length: 1))
        } else {
            XCTAssert(false, "failed to generate random URL")
        }
    }
    
    func test_orgProtocolURL_storeLink() throws {
        if let url = randomURL() {
            let body = AttributedString(randomSentence(words: 5))
            
            orgProtocolURL_testbench(pType: .storeLink,
                                     url: url,
                                     title: randomSentence(words: 5),
                                     body: body,
                                     template: randomString(length: 1))
        } else {
            XCTAssert(false, "failed to generate random URL")
        }
    }
    
    func test_orgProtocolURL_nil_url() throws {
        orgProtocolURL_testbench(pType: .storeLink, url: nil,
                                 title: nil,
                                 body: nil,
                                 template: nil)
    }
    
    func test_orgProtocolURL_nil_title() throws {
        if let url = randomURL() {
            let body = AttributedString(randomSentence(words: 5))
            
            orgProtocolURL_testbench(pType: .capture,
                                     url: url,
                                     title: nil,
                                     body: body,
                                     template: randomString(length: 1))
        } else {
            XCTAssert(false, "failed to generate random URL")
        }
    }
    
    func test_orgProtocolURL_nil_body() throws {
        if let url = randomURL() {
            orgProtocolURL_testbench(pType: .capture,
                                     url: url,
                                     title: randomSentence(words: 5),
                                     body: nil,
                                     template: randomString(length: 1))
        } else {
            XCTAssert(false, "failed to generate random URL")
        }
    }

    func test_orgProtocolURL_nil_template() throws {
        if let url = randomURL() {
            let body = AttributedString(randomSentence(words: 5))
            
            orgProtocolURL_testbench(pType: .capture,
                                     url: url,
                                     title: randomSentence(words: 5),
                                     body: body,
                                     template: nil)
        }
    }

    
    func test_orgLinkMarkup() throws {
        let capteeManager = CapteeManager()

        if let url = randomURL() {
            let title = randomSentence(words: 7)
            if let link = capteeManager.orgLinkMarkup(url: url, title: title) {
                verifyOrgLinkMarkup(link, url, title)
            }
        } else {
            XCTAssert(false, "failed to generate random URL")
        }

    }
    
    func test_orgLinkMarkup_url_only() throws {
        let capteeManager = CapteeManager()
        
        if let url = randomURL() {
            if let link = capteeManager.orgLinkMarkup(url: url, title: nil) {
                print("\(link)")
                
                let pat = Regex {
                    #"[["#
                    Capture {
                        OneOrMore {
                            CharacterClass.any
                        }
                    }
                    #"]]"#
                }
                
                if let match = link.firstMatch(of: pat) {
                    let testUrlString = String(match.1)
                    XCTAssertEqual(url.absoluteString, testUrlString)
                } else {
                    XCTAssert(false, "failed to match org link pattern \(link)")
                }
            }
        } else {
            XCTAssert(false, "failed to generate random URL")
        }
    }
    

    func test_markdownLinkMarkup () throws {
        let capteeManager = CapteeManager()

        if let url = randomURL() {
            let title = randomSentence(words: 7)
            if let link = capteeManager.markdownLinkMarkup(url: url, title: title) {
                print("\(link)")
                verifyMarkdownLinkMarkup(link, url, title)
                
            }
        } else {
            XCTAssert(false, "failed to generate random URL")
        }

    }
    
    
    func test_markdownLinkMarkup_url_only() throws {
        let capteeManager = CapteeManager()
        
        if let url = randomURL() {
            if let link = capteeManager.markdownLinkMarkup(url: url, title: nil) {
                print("\(link)")
                
                let pat = Regex {
                    #"<"#
                    Capture {
                        OneOrMore {
                            CharacterClass.any
                        }
                    }
                    #">"#
                }
                
                if let match = link.firstMatch(of: pat) {
                    let testUrlString = String(match.1)
                    XCTAssertEqual(url.absoluteString, testUrlString)
                } else {
                    XCTAssert(false, "failed to match org link pattern \(link)")
                }
            }
        } else {
            XCTAssert(false, "failed to generate random URL")
        }
    }
    
    func test_orgMessage() throws {
        let capteeManager = CapteeManager()
        let title = randomSentence(words: 5)
        let body = AttributedString(randomSentence(words: 10))
        let template = randomString(length: 2)
        
        if let url = randomURL() {
            if let message = capteeManager.orgMessage(payloadType: .capture,
                                                      url: url,
                                                      title: title,
                                                      body: body,
                                                      template: template) {
                //print("\(message)")
                let bufList = message.split(separator: "\n")
                //print("\(bufList)")
                
                XCTAssert(bufList.count == 3)
                XCTAssertEqual("* " + title, String(bufList[0]))
                verifyOrgLinkMarkup(String(bufList[1]), url, title)
                let bodyString = String(body.characters[...])
                XCTAssertEqual(bodyString, String(bufList[2]))
            }
            
            if let message = capteeManager.orgMessage(payloadType: .link,
                                                      url: url,
                                                      title: title,
                                                      body: nil,
                                                      template: nil) {
                //print("\(message)")
                verifyOrgLinkMarkup(message, url, title)
            }
        }
    }
    
    func test_markdownMessage() throws {
        let capteeManager = CapteeManager()
        let title = randomSentence(words: 5)
        let body = AttributedString(randomSentence(words: 10))

        if let url = randomURL() {
            if let message = capteeManager.markdownMessage(payloadType: .capture,
                                                           url: url,
                                                           title: title,
                                                           body: body) {
                //print("\(message)")
                let bufList = message.split(separator: "\n")
                //print("\(bufList)")
                
                XCTAssert(bufList.count == 3)
                XCTAssertEqual("# " + title, String(bufList[0]))
                verifyMarkdownLinkMarkup(String(bufList[1]), url, title)
                let bodyString = String(body.characters[...])
                XCTAssertEqual(bodyString, String(bufList[2]))
            }
            
            if let message = capteeManager.markdownMessage(payloadType: .link,
                                                           url: url,
                                                           title: title,
                                                           body: nil) {
                verifyMarkdownLinkMarkup(message, url, title)
            }
                
        }
    }

    func test_replaceOrderedListMarkers() throws {
        var bufList: [String] = []
        var controlList: [String] = []
        let index: Int = 1
        let limit: Int = 10
        let depth: Int = 2
        
        for i in index...limit {
            let sentence = randomSentence(words: 5)
            bufList.append("\t\(i).\t\(sentence)\n")
            controlList.append("\(String(repeating: "  ", count: (depth - 1)))\(i). \(sentence)\n")
        
        }
        
        let input = bufList.joined()
        let experiment = CapteeUtils.replaceOrderedListMarkers(input, depth: depth)
        let control = controlList.joined()
        XCTAssertEqual(control, experiment)
    }
    
    func test_replaceUnorderedListMarkers() throws {
        var bufList: [String] = []
        var controlList: [String] = []
        let index: Int = 1
        let limit: Int = 10
        let depth: Int = 2
        let marker = "-"
        
        for _ in index...limit {
            let sentence = randomSentence(words: 5)
            bufList.append("\t\(marker)\t\(sentence)\n")
            controlList.append("\(String(repeating: "  ", count: (depth - 1)))\(marker) \(sentence)\n")
        
        }
        
        let input = bufList.joined()
        let experiment = CapteeUtils.replaceUnorderedListMarkers(input, depth: depth)
        let control = controlList.joined()
        XCTAssertEqual(control, experiment)
    }
}
