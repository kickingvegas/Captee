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


import Foundation
import AppKit

class CXScrollableTextView: NSScrollView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.translatesAutoresizingMaskIntoConstraints = false
        createSubViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
        createSubViews()
    }

    init() {
        super.init(frame: NSMakeRect(0, 0, 700, 300))
        self.translatesAutoresizingMaskIntoConstraints = false
        createSubViews()
    }

    func createSubViews2() {
        self.borderType = .noBorder
        self.backgroundColor = .gray
        self.hasVerticalScroller = true

        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()

        textContainer.heightTracksTextView = true
        textContainer.widthTracksTextView = true
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        //self.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]


        let textView = NSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false

        self.documentView = textView

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])



    }

    func createSubViews() {
        print("scrollable text yo")
        //self.backgroundColor = .red
        self.translatesAutoresizingMaskIntoConstraints = false

        self.borderType = .noBorder
        self.backgroundColor = .gray
        self.hasVerticalScroller = true
        self.scrollerStyle = .legacy



        let clipView = NSClipView()
        clipView.translatesAutoresizingMaskIntoConstraints = false

        self.contentView = clipView

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
            //trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
            topAnchor.constraint(equalTo: clipView.topAnchor),
            bottomAnchor.constraint(equalTo: clipView.bottomAnchor)
        ])

        let textView = NSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.documentView = textView
        textView.isVerticallyResizable = true
        textView.wantsLayer = true


        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: clipView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }
}
