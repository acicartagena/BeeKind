//Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import SwiftUI

struct AddItemView: View {

    let availableGradients: [GradientOption] = TemplateGradients.allCases
    @State var currentGradientIndex: Int = 0
    var currentGradient: LinearGradient {
        availableGradients[currentGradientIndex].gradient
    }

    @State var itemText: String = ""

    var body: some View {
        ZStack {
            currentGradient
                .edgesIgnoringSafeArea(.all)
            VStack {
                Button("", action: changeCurrentGradient)
                    .buttonStyle(CircularGradientButtonStyle(currentGradient: currentGradient))
                    .padding()
                Text("I'm grateful for")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .italic()
                    .shadow(radius: 0.5)
                    .padding()
                Spacer()
                TextEditor(text: $itemText)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .shadow(radius: 0.5)
                    .padding()
                Spacer()
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

struct CircularGradientButtonStyle: ButtonStyle {
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
