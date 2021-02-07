//Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import SwiftUI

struct AddItemView: View {

    let availableGradients: [GradientOption] = TemplateGradients.allCases
    @State var currentGradientIndex: Int = 0
    var currentGradient: LinearGradient {
        availableGradients[currentGradientIndex].gradient
    }

    var body: some View {
        ZStack {
            currentGradient
                .edgesIgnoringSafeArea(.all)
            VStack {
                Button("", action: changeCurrentGradient)
                    .buttonStyle(CircularButtonStyle(currentGradient: currentGradient))
                Text("add item")
            }
        }
    }

    func changeCurrentGradient() {
        let newIndex = currentGradientIndex + 1
        guard availableGradients.indices.contains(newIndex) else {
            currentGradientIndex = 0
            return
        }
        currentGradientIndex = newIndex
    }
}

struct CircularButtonStyle: ButtonStyle {
    let currentGradient: LinearGradient

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration
            .label
            .frame(width: 50, height: 50)
            .background(currentGradient)
            .overlay(Circle().stroke(Color.white, lineWidth: 5))
            .clipShape(Circle())
    }
}
