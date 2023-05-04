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

struct OrgURLView: View {
    @ObservedObject var capteeViewModel: CapteeViewModel
    
    @State var foregroundColor: Color = .black

    var body: some View {
        TextField("URL", text: $capteeViewModel.urlString)
            .textFieldStyle(.plain)
            .font(.system(size: 16))
            .help("Org Capture Link URL")
            .onChange(of: capteeViewModel.urlString) { newValue in
                if capteeViewModel.isURLValid || newValue == "" {
                    foregroundColor = .primary
                } else {
                    foregroundColor = .red
                }
            }
            .foregroundColor(foregroundColor)
        
        Divider()
    }
}
