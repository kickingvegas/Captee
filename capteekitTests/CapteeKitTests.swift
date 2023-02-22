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

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

func randomSentence(length: Int) -> String {
    var sentence = [String]()
    for _ in 1...length {
        sentence.append(randomString(length: Int.random(in: 1..<10)))
    }
    
    let result = sentence.joined(separator: " ")
    return result
}

final class CapteeKitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_orgProtocolURL_streamLink() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        
        let capteeManager = CapteeManager()
        
        let urlString = "http://google.com?mar=sdf&sdf=333"
        let title = randomSentence(length: 3)
        let body:String? = nil
        let template:String? = "b"
            
        if let url = capteeManager.orgProtcolURL(host: .storeLink,
                                                 url: URL(string: urlString),
                                                 title: title,
                                                 body: body,
                                                 template: template) {

            if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                XCTAssertTrue(urlComponents.scheme == "org-protocol")
                XCTAssertTrue(urlComponents.host == OrgProtocolHost.storeLink.rawValue)
                
                if let queryItems = urlComponents.queryItems {
                    print("\(queryItems)")
                    
                    for item in queryItems {
                        if item.name == "title" {
                            XCTAssertTrue(item.value == title)
                        } else if item.name == "url" {
                            XCTAssertTrue(item.value == urlString)
                        } else if item.name == "body" {
                            XCTAssertTrue(item.value == body)
                        } else if item.name == "template" {
                            XCTAssertTrue(item.value == template)
                        }
                    }
                }
                
                print("\(url.absoluteString)")

            }
        }
    }
}
