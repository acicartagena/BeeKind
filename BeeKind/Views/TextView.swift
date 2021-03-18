// Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import UIKit
import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    var maxCharacterCount: Int?
    var isFirstResponder: Bool = false
    var textStyle: UIFont.TextStyle = .title2

    func makeUIView(context: Self.Context) -> UITextView {
        let uiView =  UITextView()
        uiView.textColor = UIColor.white
        uiView.backgroundColor = UIColor.clear
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
        uiView.clipsToBounds = true
        uiView.layer.masksToBounds = true
        uiView.layer.cornerRadius = 16.0
        uiView.delegate = context.coordinator
        uiView.text = text
        return uiView
    }

    func updateUIView(_ uiView: UITextView, context: Self.Context) {
        if !isFirstResponder && !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, maxCharacterCount: maxCharacterCount)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var control: TextView
        var didBecomeFirstResponder = false
        var maxCharacterCount: Int?

        init(_ control: TextView, maxCharacterCount: Int?) {
            self.control = control
            self.maxCharacterCount = maxCharacterCount
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard let maxCharacterCount = self.maxCharacterCount else { return true }
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            return newText.count <= maxCharacterCount
        }

        func textViewDidChange(_ textView: UITextView) {
            self.control.text = textView.text
        }
    }
}
