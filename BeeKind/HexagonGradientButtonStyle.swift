// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI

struct HexagonGradientButtonStyle: ButtonStyle {
    let currentGradient: LinearGradient

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration
            .label
            .frame(width: 50, height: 50)
            .background(currentGradient)
            .overlay(Hexagon().stroke(Color.white, lineWidth: 5))
            .clipShape(Hexagon())
    }
}
