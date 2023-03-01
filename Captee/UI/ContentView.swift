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

struct ContentView: View {
    @State var urlText: String = ""
    @State var titleText: String = ""
    @State var templateText: String = ""
    
    // TODO: convert to AttributedString
    // https://developer.apple.com/forums/thread/682431
    
    @State var bodyText: AttributedString = AttributedString("hey there")
    @State var orghost: OrgProtocolHost = .storeLink
    
    var body: some View {
        
        VStack (alignment: .leading) {
            Picker("Protocol", selection: $orghost) {
                ForEach(OrgProtocolHost.allCases, id: \.self) { value in
                    Text(value.rawValue)
                        .tag(value)
                }
            }.pickerStyle(.radioGroup)
            Divider()
            TextField("URL", text: $urlText)
                .textFieldStyle(.plain)
                .help("Org Capture Link URL")
            
            Divider()
            TextField("Title", text: $titleText)
                .textFieldStyle(.plain)
                .help("Org Capture Link Title")
            Divider()
            
            Text("Body Text")
                .help("Enter body text")
                .foregroundColor(.gray)
            
            CAPTextEditor(text: $bodyText)
                .textFieldStyle(.roundedBorder)
            

            HStack(alignment: .bottom) {
                Spacer()
                Button("Capture") {
                }
                .frame(alignment: .trailing)
                .buttonStyle(.borderedProminent)
                .help("Send to Org")
            }
        }
        .padding(EdgeInsets(top: 10, leading: 60, bottom: 10, trailing: 90))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
