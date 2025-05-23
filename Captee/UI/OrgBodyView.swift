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

struct OrgBodyView: View {
    @ObservedObject var capteeViewModel: CapteeViewModel
    var body: some View {
        VStack {
            HStack {
                Text("Body Text")
                    .font(.system(size: 16))
                    .help("Enter body text")
                    .foregroundColor(.gray)
                Spacer()
                
                Toggle(isOn: $capteeViewModel.stripFormatting) {
                    Text("Strip Formatting")
                }
                .toggleStyle(.checkbox)
                .help("Do not include formatting in captured text.")
            }
            
            CAPTextEditor(text: $capteeViewModel.body)
                .textFieldStyle(.roundedBorder)
                .onChange(of: capteeViewModel.body) { newValue in
                }
        }
    }
}

#Preview {
    OrgBodyView(capteeViewModel: CapteeViewModel())
}
