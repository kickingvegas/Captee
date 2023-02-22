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

struct ContentView: View {
    @State var urlText: String = ""
    @State var titleText: String = ""
    @State var templateText: String = ""
    @State var bodyText: NSAttributedString = NSAttributedString(string: "hey they clittiak")
    
    var body: some View {
        VStack (alignment: .someFooAlignment) {
            HStack(alignment: .center) {
                Text("URL")
                    .multilineTextAlignment(.trailing)
                    .alignmentGuide(.someFooAlignment, computeValue: { d in d[.trailing]})
                TextField("URL", text: $urlText)
            }
            
            HStack(alignment: .center) {
                Text("Title")
                    .multilineTextAlignment(.trailing)
                    .alignmentGuide(.someFooAlignment, computeValue: { d in d[.trailing]})
                TextField("Title", text: $titleText)
            }
            
            HStack(alignment: .top) {
                Text("Body")
                    .multilineTextAlignment(.trailing)
                    .alignmentGuide(.someFooAlignment, computeValue: { d in d[.trailing]})
                // TODO: need to wrap NSTextView here. https://sarunw.com/posts/uikit-in-swiftui/
                
                CAPTextEditor(text: $bodyText)
                //TextEditor(text: $bodyText)
            }
            
            HStack {
                Text("Template")
                    .multilineTextAlignment(.trailing)
                    .alignmentGuide(.someFooAlignment, computeValue: { d in d[.trailing]})
                    .padding(.leading, 30)
                TextField("template id", text: $templateText)
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 60, bottom: 10, trailing: 90))
    }
}


extension HorizontalAlignment {
    private struct SomeFooAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.trailing]
        }
    }
    
    static let someFooAlignment = HorizontalAlignment(SomeFooAlignment.self)
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
