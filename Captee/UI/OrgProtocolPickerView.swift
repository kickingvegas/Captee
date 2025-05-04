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

struct OrgProtocolPickerView: View {
    @ObservedObject var capteeViewModel: CapteeViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Format", selection: $capteeViewModel.markupFormat) {
                    ForEach(MarkupFormat.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                            .font(.system(size: 16))
                    }
                }
                .font(.system(size: 16))
                .pickerStyle(.radioGroup)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 20))
                .onChange(of: capteeViewModel.markupFormat) { newValue in
                    if newValue == .markdown {
                        capteeViewModel.transmitPickerDisabled = true
                        capteeViewModel.transmitType = .clipboard

                    } else if newValue == .orgMode {
                        if capteeViewModel.isOrgProtocolSupported {
                            capteeViewModel.transmitPickerDisabled = false
                        }
                    }
                }

                Picker("Payload", selection: $capteeViewModel.payloadType) {
                    ForEach(PayloadType.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                            .font(.system(size: 16))
                    }
                }
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                .pickerStyle(.radioGroup)
                .onChange(of: capteeViewModel.payloadType) { newValue in
                }

                Picker("Use", selection: $capteeViewModel.transmitType) {
                    ForEach(TransmitType.allCases, id: \.self) { value in
                        Text(value.rawValue)
                            .tag(value)
                            .font(.system(size: 16))
                    }
                }
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                .pickerStyle(.radioGroup)
                .disabled(capteeViewModel.transmitPickerDisabled || !capteeViewModel.isOrgProtocolSupported)

                Spacer()
                VStack {
                    Text("Drag URL here")
                        .font(.system(size: 16))
                }
                .padding(EdgeInsets(top: 15, leading: 35, bottom: 15, trailing: 35))
                .background(Color.teal)
                .dropDestination(for: URL.self) { items, location in
                    if let url = items.first {
                        print("\(url.absoluteString)")
                        capteeViewModel.urlString = url.absoluteString

                        capteeViewModel.isNetworkRequestInProgress = true
                        capteeViewModel.extractTitleFromURL(url: url) { result in
                            switch result {
                            case .success(let extractedTitle):
                                DispatchQueue.main.async {
                                    capteeViewModel.isNetworkRequestInProgress = false
                                    capteeViewModel.title = extractedTitle
                                }

                            case .failure(let error):
                                DispatchQueue.main.async {
                                    capteeViewModel.isNetworkRequestInProgress = false
                                    capteeViewModel.title = ""
                                    let localError = error as CapteeError
                                    switch localError {
                                    case .invalidURLScheme:
                                        capteeViewModel.alertTitle = "Only TLS URLs supported"
                                        capteeViewModel.alertMessage = "Captee cannot request a non-TLS URL to read its title. If desired, please directly copy it over."
                                    case .networkError(error: let internalError):
                                        capteeViewModel.alertTitle = "Network Error"
                                        capteeViewModel.alertMessage = "Unable to access the network. (\(internalError.localizedDescription))"
                                    case .titleNotFound:
                                        capteeViewModel.alertTitle = "Page Title Not Found"
                                        capteeViewModel.alertMessage = "Unable to extract the title for URL page. Try manually copying or editing the title."
                                    case .encodeStringToDataFailed:
                                        capteeViewModel.alertTitle = "Title Processing Error"
                                        capteeViewModel.alertMessage = "Failed to encode the title string to data. (encodeStringToDataFailed)"
                                    case .attributedStringCreationFailed(error: let internalError):
                                        capteeViewModel.alertTitle = "Title Processing Error"
                                        capteeViewModel.alertMessage = "Failed to decode the HTML entities in the title. (\(internalError.localizedDescription))"
                                    }
                                    capteeViewModel.isAlertRaised = true
                                }
                            }
                        }
                    }
                    return true
                }
            }
            Divider()
        }
    }
}
