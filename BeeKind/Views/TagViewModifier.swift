// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI

struct TagViewModifier: ViewModifier {
    let backgroundColor: Color
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .background(backgroundColor)
            .cornerRadius(12.0)
    }
}

extension View {
    func tag(backgroundColor: Color) -> some View {
        self.modifier(TagViewModifier(backgroundColor: backgroundColor))
    }
}
