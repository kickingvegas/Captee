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

import XCTest
@testable import CapteeKit

final class MarkupDialectTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_MarkdownStyleDelimiter() throws {
        XCTAssertEqual(MarkdownStyleDelimiter.emphasis.rawValue, "*")
        XCTAssertEqual(MarkdownStyleDelimiter.strong.rawValue, "**")
        XCTAssertEqual(MarkdownStyleDelimiter.code.rawValue, "`")
        XCTAssertEqual(MarkdownStyleDelimiter.underline.rawValue, "")
        XCTAssertEqual(MarkdownStyleDelimiter.strikethrough.rawValue, "~")
    }

    func test_OrgStyleDelimiter() throws {
        XCTAssertEqual(OrgStyleDelimiter.emphasis.rawValue, "/")
        XCTAssertEqual(OrgStyleDelimiter.strong.rawValue, "*")
        XCTAssertEqual(OrgStyleDelimiter.code.rawValue, "~")
        XCTAssertEqual(OrgStyleDelimiter.underline.rawValue, "_")
        XCTAssertEqual(OrgStyleDelimiter.strikethrough.rawValue, "+")
    }

    func styleDelimiterTestWithNewline(delimiter: String, dialect: MarkupProtocol) -> (content: String, control: String) {
        let base = randomString(length: 20)
        let content = base + "\n"
        let control = "\(delimiter)\(base)\(delimiter)\n"
        return (content, control)
    }

    func styleDelimiterTest(delimiter: String, dialect: MarkupProtocol) -> (content: String, control: String) {
        let content = randomString(length: 20)
        let control = "\(delimiter)\(content)\(delimiter)"
        return (content, control)
    }

    func test_markdown_styles() throws {
        let dialect = MarkdownDialect()
        for delimiter in MarkdownStyleDelimiter.allCases {
            let (content, control) = styleDelimiterTest(delimiter: delimiter.rawValue, dialect: dialect)
            let experiment = dialect.style(content, delimiter: delimiter)
            XCTAssertEqual(control, experiment)

            let (content2, control2) = styleDelimiterTestWithNewline(delimiter: delimiter.rawValue, dialect: dialect)
            let experiment2 = dialect.style(content2, delimiter: delimiter)
            XCTAssertEqual(control2, experiment2)
        }
    }

    func test_org_styles() throws {
        let dialect = OrgDialect()
        for delimiter in OrgStyleDelimiter.allCases {
            let (content, control) = styleDelimiterTest(delimiter: delimiter.rawValue, dialect: dialect)
            let experiment = dialect.style(content, delimiter: delimiter)
            XCTAssertEqual(control, experiment)

            let (content2, control2) = styleDelimiterTestWithNewline(delimiter: delimiter.rawValue, dialect: dialect)
            let experiment2 = dialect.style(content2, delimiter: delimiter)
            XCTAssertEqual(control2, experiment2)
        }
    }

    func headerTest(delimiter: String, dialect: MarkupProtocol) throws {
        let content = randomString(length: 38)
        for level in -2...6 {
            var control: String = ""
            let experiment = dialect.header(content, level: level)
            if level > 0 {
                control = "\(String(repeating: delimiter, count: level)) \(content)"
            } else {
                control = "\(content)"
            }

            XCTAssertEqual(control, experiment)
        }

        let content2 = "\n"
        let experiment2 = dialect.header(content2, level: 1)
        XCTAssertEqual(content2, experiment2)

    }

    func test_markdown_header() throws {
        let dialect = MarkdownDialect()
        let delimiter = "#"
        try headerTest(delimiter: delimiter, dialect: dialect)
    }

    func test_org_header() throws {
        let dialect = OrgDialect()
        let delimiter = "*"
        try headerTest(delimiter: delimiter, dialect: dialect)
    }

    func test_markdown_link() throws {
        let dialect = MarkdownDialect()

        if let url = randomURL() {
            let description = randomSentence(words: 5)
            let link = dialect.link(url, description: description)
            let control = "[\(description)](\(url.absoluteString))"
            XCTAssertEqual(control, link)

            let experiment2 = dialect.link(url)
            let control2 = "<\(url.absoluteString)>"
            XCTAssertEqual(control2, experiment2)
        }
    }

    func test_org_link() throws {
        let dialect = OrgDialect()

        if let url = randomURL() {
            let description = randomSentence(words: 5)
            let link = dialect.link(url, description: description)
            let control = "[[\(url.absoluteString)][\(description)]]"
            XCTAssertEqual(control, link)

            let experiment2 = dialect.link(url)
            let control2 = "[[\(url.absoluteString)]]"
            XCTAssertEqual(control2, experiment2)
        }
    }
}
