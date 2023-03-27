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
    @StateObject var capteeViewModel = CapteeViewModel()

    var body: some View {
        VStack (alignment: .leading) {
            OrgProtocolPickerView(capteeViewModel: capteeViewModel)
            OrgURLView(capteeViewModel: capteeViewModel)
            OrgTitleView(capteeViewModel: capteeViewModel)
            if !capteeViewModel.hideTemplate {
                OrgTemplateView(capteeViewModel: capteeViewModel)
            }
            if !capteeViewModel.hideBody {
                OrgBodyView(capteeViewModel: capteeViewModel)
            } else {
                Spacer()
            }

            HStack(alignment: .bottom) {
                Spacer()
                Button("Capture") {
                    captureAction()
                }
                .alert(isPresented: $capteeViewModel.showSentToClipboardAlert) {
                    return Alert(title: Text(capteeViewModel.alertTitle),
                                 message: Text(capteeViewModel.alertMessage),
                                 dismissButton: .default(Text("Dismiss")))
                }

                .frame(alignment: .trailing)
                .buttonStyle(.borderedProminent)
                .disabled(capteeViewModel.sendButtonDisabled)
                .help("Send to Org")
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
    }
    
    func captureAction() {
        capteeViewModel.captureAction { result in
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
    @ObservedObject var capteeViewModel: CapteeViewModel

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("Template Key")
                .foregroundColor(.gray)
            TextField("Key", text: $capteeViewModel.template)
                .textFieldStyle(.plain)
            .help("Org Capture Link Template Key")
            .disabled(capteeViewModel.orgProtocol == .storeLink)
        }
        
        Divider()
    }
        
}

struct OrgTitleView: View {
    @ObservedObject var capteeViewModel: CapteeViewModel
    
    var body: some View {
        TextField("Title", text: $capteeViewModel.title)
            .textFieldStyle(.plain)
            .help("Org Capture Link Title")
        Divider()
    }
}

struct OrgURLView: View {
    @ObservedObject var capteeViewModel: CapteeViewModel
    
    @State var foregroundColor: Color = .black

    var body: some View {
        TextField("URL", text: $capteeViewModel.urlString)
            .textFieldStyle(.plain)
            .help("Org Capture Link URL")
            .onChange(of: capteeViewModel.urlString) { newValue in
                //print("\(newValue)")
                
                capteeViewModel.isURLValid = CapteeUtils.validateURL(string: newValue)
                
                if capteeViewModel.isURLValid || newValue == "" {
                    foregroundColor = .primary
                } else {
                    foregroundColor = .red
                }
                
                capteeViewModel.evalEnableSendButton()

            }
            .foregroundColor(foregroundColor)
        
        Divider()
    }
}

struct OrgBodyView: View {
    @ObservedObject var capteeViewModel: CapteeViewModel

    var body: some View {
        Text("Body Text")
            .help("Enter body text")
            .foregroundColor(.gray)
        
        CAPTextEditor(text: $capteeViewModel.body)
            .textFieldStyle(.roundedBorder)
            .disabled(capteeViewModel.bodyDisabled)
            .onChange(of: capteeViewModel.body) { newValue in
                capteeViewModel.evalEnableSendButton()
            }
    }
}

struct OrgProtocolPickerView: View {
    @ObservedObject var capteeViewModel: CapteeViewModel
    //@State var sendDisable: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Format", selection: $capteeViewModel.markupFormat) {
                    ForEach(MarkupFormat.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: capteeViewModel.markupFormat) { newValue in
                    if newValue == .markdown {
                        capteeViewModel.sendtoPickerDisabled = true
                        capteeViewModel.sendtoType = .clipboard
                        capteeViewModel.hideTemplate = true

                    } else if newValue == .orgMode {
                        if capteeViewModel.isOrgProtocolSupported {
                            capteeViewModel.sendtoPickerDisabled = false
                            //capteeViewModel.sendtoType = .orgProtocol
                        }
                        capteeViewModel.hideTemplate = false
                    }
                    
                }

                
                Picker("Payload", selection: $capteeViewModel.payloadType) {
                    ForEach(PayloadType.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: capteeViewModel.payloadType) { newValue in
                    if newValue == .capture {
                        capteeViewModel.bodyDisabled = false
                        capteeViewModel.orgProtocol = .capture
                        capteeViewModel.hideBody = false
                        if capteeViewModel.markupFormat == .orgMode {
                            capteeViewModel.hideTemplate = false
                        } else {
                            capteeViewModel.hideTemplate = true
                        }
                        
                    } else if newValue == .link {
                        capteeViewModel.bodyDisabled = true
                        capteeViewModel.orgProtocol = .storeLink
                        capteeViewModel.hideTemplate = true
                        capteeViewModel.hideBody = true
                    }
                    capteeViewModel.evalEnableSendButton()
                }
                
                Picker("Use", selection: $capteeViewModel.sendtoType) {
                    ForEach(SendtoType.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                .pickerStyle(.radioGroup)
                .disabled(capteeViewModel.sendtoPickerDisabled || !capteeViewModel.isOrgProtocolSupported)

            }
            Divider()
        }
    }
}
