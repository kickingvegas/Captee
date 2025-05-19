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

import SwiftUI
import CapteeKit
import OSLog

struct ContentView: View {
    fileprivate let logger = Logger(subsystem: "com.yummymelon.Captee", category: "UI")
    @StateObject var capteeViewModel = CapteeViewModel()

    var body: some View {
        VStack (alignment: .leading) {
            OrgProtocolPickerView(capteeViewModel: capteeViewModel)
            OrgURLView(capteeViewModel: capteeViewModel)
            OrgTitleView(capteeViewModel: capteeViewModel)
            if !capteeViewModel.isTemplateHidden() {
                OrgTemplateView(capteeViewModel: capteeViewModel)
            }
            if !capteeViewModel.isBodyHidden() {
                OrgBodyView(capteeViewModel: capteeViewModel)
            } else {
                Spacer()
            }

            HStack(alignment: .bottom) {
                Spacer()
                Button("Capture") {
                    captureAction()
                }
                .font(.system(size: 16))
                .frame(alignment: .trailing)
                .buttonStyle(.borderedProminent)
                .disabled(capteeViewModel.sendButtonDisabled)
                .controlSize(.large)
                .help("Send to Org")
            }
        }
        .alert(isPresented: $capteeViewModel.isAlertRaised) {
            return Alert(title: Text(capteeViewModel.alertTitle),
                         message: Text(capteeViewModel.alertMessage),
                         dismissButton: .default(Text("Dismiss")))
        }
        .confirmationDialog("Welcome and thank you for getting Captee!\nCaptee needs the macOS permission to be in the Share menu. Please click below to learn how.", isPresented: $capteeViewModel.showOnboardingAlert, titleVisibility: .visible) {
            Button("Show me how to enable Captee in the Share menu") {
                if let bookName = Bundle.main.object(forInfoDictionaryKey: "CFBundleHelpBookName") as? String {
                    NSHelpManager.shared.openHelpAnchor("ShareMenuPermission", inBook: bookName)
                }
            }
            Button("No, I'm good. (above instructions are always in the Help menu)", role: .cancel) {}
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
    }

    func captureAction() {
        capteeViewModel.captureAction { result in
            logger.debug("\(result)")
        }
    }
}

#Preview {
    ContentView().frame(width: 800, height: 600)
}
