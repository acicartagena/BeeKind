// Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import UIKit
import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Self.Context) -> UITextView {
        let uiView =  UITextView()
        uiView.textColor = UIColor.white
        uiView.backgroundColor = UIColor.clear
        uiView.font = UIFont.preferredFont(forTextStyle: .title2)
        uiView.clipsToBounds = true
        uiView.layer.masksToBounds = true
        uiView.layer.cornerRadius = 16.0
        return uiView
    }

    func updateUIView(_ uiView: UITextView, context: Self.Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var control: TextView

        init(_ control: TextView) {
            self.control = control
        }
    }
}
