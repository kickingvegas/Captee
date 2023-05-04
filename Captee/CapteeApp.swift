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

@main
struct CapteeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                EmptyView()
            }
            
            CommandGroup(after: .help) {
                Divider()
                
                Button("Rate and Review") {
                    guard let url = URL(string: "https://apps.apple.com/us/app/captee/id6446053750?action=write-review") else {
                        fatalError("unable to generate URL")
                    }
                    NSWorkspace.shared.open(url)
                }
                .help("Your feedback is important to us! Please rate and review Captee on the App Store.")

                Divider()
                
                Button("Online Discussions") {
                    guard let url = URL(string: "https://github.com/kickingvegas/Captee/discussions") else {
                        fatalError("unable to generate URL")
                    }
                    NSWorkspace.shared.open(url)
                }
                .help("Join the community on GitHub and discuss how you use Captee with others!")
                
                Divider()
                
                Button("Captee Source") {
                    guard let url = URL(string: "https://github.com/kickingvegas/Captee") else {
                        fatalError("unable to generate URL")
                    }
                    NSWorkspace.shared.open(url)
                }
                .help("Want to know what's inside? Peruse the source code for Captee on GitHub.")
            }
        }
    }
}
