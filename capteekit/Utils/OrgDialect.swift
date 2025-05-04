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


import Foundation

enum OrgStyleDelimiter: String, CaseIterable {
    case emphasis = "/"
    case strong = "*"
    case code = "~"
    case underline = "_"
    case strikethrough = "+"
}

struct OrgDialect: MarkupProtocol {
    func header(_ buf: String, level: Int) -> String {
        guard level > 0 else {
            print("WARNING: non-positive level input: \(level)")
            return buf
        }
        guard buf != "\n" else { return buf }
        return String(repeating: "*", count: level) + " " + buf
    }

    func emphasis(_ buf: String) -> String {
        CapteeUtils.delimitString(buf: buf, delimiter: OrgStyleDelimiter.emphasis.rawValue)
    }

    func strong(_ buf: String) -> String {
        CapteeUtils.delimitString(buf: buf, delimiter: OrgStyleDelimiter.strong.rawValue)
    }

    func code(_ buf: String) -> String {
        CapteeUtils.delimitString(buf: buf, delimiter: OrgStyleDelimiter.code.rawValue)
    }

    func underline(_ buf: String) -> String {
        CapteeUtils.delimitString(buf: buf, delimiter: OrgStyleDelimiter.underline.rawValue)
    }

    func strikethrough(_ buf: String) -> String {
        CapteeUtils.delimitString(buf: buf, delimiter: OrgStyleDelimiter.strikethrough.rawValue)
    }

    func style(_ buf: String, delimiter: OrgStyleDelimiter) -> String {
        switch delimiter {
        case .emphasis:
            return emphasis(buf)
        case .strong:
            return strong(buf)
        case .code:
            return code(buf)
        case .underline:
            return underline(buf)
        case .strikethrough:
            return strikethrough(buf)
        }
    }

    func link(_ url: URL, description: String? = nil) -> String {
        if let description = description {
            return "[[\(url.absoluteString)][\(description)]]"
        } else {
            return "[[\(url.absoluteString)]]"
        }
    }
}
