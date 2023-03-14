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
    @StateObject var capteeObservableManager = CapteeObservableManager()

    var body: some View {
        VStack (alignment: .leading) {
            OrgProtocolPickerView(capteeObservableManager: capteeObservableManager)
            OrgURLView(capteeObservableManager: capteeObservableManager)
            OrgTitleView(capteeObservableManager: capteeObservableManager)
            if !capteeObservableManager.hideTemplate {
                OrgTemplateView(capteeObservableManager: capteeObservableManager)
            }
            OrgBodyView(capteeObservableManager: capteeObservableManager)

            HStack(alignment: .bottom) {
                Spacer()
                Button("Capture") {
                    captureAction()
                }
                .alert(isPresented: $capteeObservableManager.showOrgProtocolNotSupportedAlert) {
                    let message = "You do not have installed a version of Emacs that supports the org-protocol:// scheme."
                    return Alert(title: Text("Missing Org Protocol"),
                                 message: Text(message),
                                 dismissButton: .default(Text("Dismiss")))
                }

                .frame(alignment: .trailing)
                .buttonStyle(.borderedProminent)
                .help("Send to Org")
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
    }
    
    func captureAction() {
        capteeObservableManager.captureAction { result in
            print("\(result)")
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct OrgTemplateView: View {
    @ObservedObject var capteeObservableManager: CapteeObservableManager

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("Template Key")
                .foregroundColor(.gray)
            TextField("Key", text: $capteeObservableManager.template)
                .textFieldStyle(.plain)
            .help("Org Capture Link Template Key")
            .disabled(capteeObservableManager.orgProtocol == .storeLink)
        }
        
        Divider()
    }
        
}

struct OrgTitleView: View {
    @ObservedObject var capteeObservableManager: CapteeObservableManager
    
    var body: some View {
        TextField("Title", text: $capteeObservableManager.title)
            .textFieldStyle(.plain)
            .help("Org Capture Link Title")
        
        Divider()
    }
}

struct OrgURLView: View {
    @ObservedObject var capteeObservableManager: CapteeObservableManager
    
    @State var foregroundColor: Color = .black

    var body: some View {
        TextField("URL", text: $capteeObservableManager.urlString)
            .textFieldStyle(.plain)
            .help("Org Capture Link URL")
            .onChange(of: capteeObservableManager.urlString) { newValue in
                print("\(newValue)")
                
                if let _ = URL(string: newValue) {
                    foregroundColor = .black
                } else if newValue == "" {
                    foregroundColor = .black
                } else {
                    foregroundColor = .red
                }

            }
            .foregroundColor(foregroundColor)
        
        Divider()
    }
}

struct OrgBodyView: View {
    @ObservedObject var capteeObservableManager: CapteeObservableManager

    var body: some View {
        Text("Body Text")
            .help("Enter body text")
            .foregroundColor(.gray)
        
        CAPTextEditor(text: $capteeObservableManager.body)
            .textFieldStyle(.roundedBorder)
            .disabled(capteeObservableManager.bodyDisabled)
    }
}

struct OrgProtocolPickerView: View {
    @ObservedObject var capteeObservableManager: CapteeObservableManager
    //@State var sendDisable: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Format", selection: $capteeObservableManager.markupFormat) {
                    ForEach(MarkupFormat.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: capteeObservableManager.markupFormat) { newValue in
                    if newValue == .markdown {
                        capteeObservableManager.sendtoPickerDisabled = true
                        capteeObservableManager.sendtoType = .clipboard
                        capteeObservableManager.hideTemplate = true

                    } else if newValue == .orgMode {
                        capteeObservableManager.sendtoPickerDisabled = false
                        capteeObservableManager.sendtoType = .orgProtocol
                        capteeObservableManager.hideTemplate = false
                    }
                    
                }

                
                Picker("Payload", selection: $capteeObservableManager.payloadType) {
                    ForEach(PayloadType.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: capteeObservableManager.payloadType) { newValue in
                    if newValue == .capture {
                        capteeObservableManager.bodyDisabled = false
                        capteeObservableManager.orgProtocol = .capture
                    } else {
                        capteeObservableManager.bodyDisabled = true
                        capteeObservableManager.orgProtocol = .storeLink
                    }
                }
                
                Picker("Use", selection: $capteeObservableManager.sendtoType) {
                    ForEach(SendtoType.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                .pickerStyle(.radioGroup)
                .disabled(capteeObservableManager.sendtoPickerDisabled)

            }
            Divider()
        }
    }
}
