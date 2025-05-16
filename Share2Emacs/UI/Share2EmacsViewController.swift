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

import Cocoa
import CapteeKit
import OSLog


class Share2EmacsViewController: NSViewController {
    fileprivate let logger = Logger(subsystem: "com.yummymelon.Captee", category: "Share2Emacs")
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var payloadPicker: CXRadioPicker!
    @IBOutlet weak var formatPicker: CXRadioPicker!
    @IBOutlet weak var transmitPicker: CXRadioPicker!
    @IBOutlet weak var helpButton: NSButton!

    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var templateField: NSTextField!
    @IBOutlet weak var templateLine: NSBox!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var scrollableTextView: NSScrollView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var stripFormattingButton: NSButton!
    var shareCXCoordinator: ShareCXCoordinator?
    
    
    override func loadView() {
        super.loadView()
        initUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        if let window = view.window {
            window.makeFirstResponder(titleField)
        }
    }

    override var nibName: NSNib.Name? {
        return NSNib.Name("Share2EmacsViewController")
    }

    private func initUI() {
        CXRadioPickerMaps.configurePickerUI(formatPicker, stringMap: CapteeKit.Constants.formatPickerDB)
        CXRadioPickerMaps.configurePickerUI(payloadPicker, stringMap: CapteeKit.Constants.payloadPickerDB)
        CXRadioPickerMaps.configurePickerUI(transmitPicker, stringMap: CapteeKit.Constants.transmitPickerDB)

        let viewModel = CapteeViewModel()

        let cxCoordinator = ShareCXCoordinator(viewModel: viewModel,
                                               formatPicker: formatPicker,
                                               payloadPicker: payloadPicker,
                                               transmitPicker: transmitPicker,
                                               urlField: urlField,
                                               titleField: titleField,
                                               templateField: templateField,
                                               templateLine: templateLine,
                                               textView: textView,
                                               scrollableTextView: scrollableTextView,
                                               sendButton: sendButton,
                                               stripFormattingButton: stripFormattingButton,
                                               progressIndicator: progressIndicator)

        // populate
        guard let extensionContext = self.extensionContext else {
            return
        }

        cxCoordinator.configureTextStorage(extensionContext: extensionContext)
        cxCoordinator.configureTemplateField()
        cxCoordinator.configureLinkFields(extensionContext: extensionContext)

        // !!!: At this point everything should be at a stable state.
        cxCoordinator.initCancellables()

        self.shareCXCoordinator = cxCoordinator
    }

    @IBAction func sendAction(_ sender: Any) {
        logger.debug("Send")
        let outputItem = NSExtensionItem()

        if let shareCXCoordinator = self.shareCXCoordinator {
            shareCXCoordinator.send()
        }

        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
    }

    @IBAction func stripFormattingAction(_ sender: Any) {
        logger.debug("strip me")
        shareCXCoordinator?.syncStripFormatting()
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        logger.debug("Cancel")
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

    @IBAction func helpAction(_ sender: Any) {
        if let bookName = Bundle(for: Share2EmacsViewController.self).object(forInfoDictionaryKey: "CFBundleHelpBookName") as? String {
            NSHelpManager.shared.openHelpAnchor("CapteeUserGuide", inBook: bookName)
        }
    }
}
