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

struct OrgTitleView: View {
    @ObservedObject var capteeViewModel: CapteeViewModel

    var body: some View {
        HStack {
            TextField("Title", text: $capteeViewModel.title)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .help("Org Capture Link Title")

            if capteeViewModel.isNetworkRequestInProgress {
                ProgressView()
                    .frame(height: 12)
                    .scaleEffect(x:0.5, y:0.5)
            }
        }
        Divider()
    }
}
