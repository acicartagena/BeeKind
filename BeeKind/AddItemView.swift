//Copyright © 2021 acicartagena. All rights reserved.// Copyright © 2021 acicartagena. All rights reserved.

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
                Spacer()
                Text("I'm grateful for")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .italic()
                    .shadow(radius: 0.8)
                TextView(text: $itemText)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16.0).fill(Color.white.opacity(0.2)))
                    .padding()
                Button("", action: changeCurrentGradient)
                    .buttonStyle(CircularGradientButtonStyle(currentGradient: currentGradient))
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

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
    }
}
