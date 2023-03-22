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


import Cocoa

protocol LoadableNib {
    var contentView: NSView! { get }
}

extension LoadableNib where Self: NSView {

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        _ = nib.instantiate(withOwner: self, topLevelObjects: nil)

        let contentConstraints = contentView.constraints
        contentView.subviews.forEach({ addSubview($0) })

        for constraint in contentConstraints {
            let firstItem = (constraint.firstItem as? NSView == contentView) ? self : constraint.firstItem
            let secondItem = (constraint.secondItem as? NSView == contentView) ? self : constraint.secondItem
            addConstraint(NSLayoutConstraint(item: firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
        }
    }
}

public enum CXRadioPickerSelected: String, Equatable, CaseIterable {
    case radio1
    case radio2
}

class CXRadioPicker: NSControl, LoadableNib, ObservableObject {
    
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var radio1: NSButton!
    @IBOutlet weak var radio2: NSButton!
    @IBOutlet weak var label: NSTextField!
    
    @Published var selection: CXRadioPickerSelected? {
        didSet {
            switch selection {
            case .radio1:
                radio1.state = .on
            case .radio2:
                radio2.state = .on
            default:
                radio1.state = .off
                radio2.state = .off
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            for obj in [radio1, radio2, label] {
                obj?.isEnabled = isEnabled
            }
        }
    }
    
    var title: String {
        get {
            label.stringValue
        }
        set {
            label.stringValue = newValue
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        loadViewFromNib()
    }

    
    @IBAction func buttonAction(_ sender: Any) {
        let radio = sender as! NSButton
        if radio == radio1 {
            selection = .radio1
        } else {
            selection = .radio2
        }
    }
    
   
}
