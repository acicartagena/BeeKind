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
    var itemTextMaxCharacters = 140
    var itemTextRemainingCharacters: String {
        "\(itemTextMaxCharacters - itemText.count)/\(itemTextMaxCharacters)"
    }

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
                HStack {
                    Spacer()
                    Text(itemTextRemainingCharacters)
                }
                TextView(text: $itemText, maxCharacterCount: itemTextMaxCharacters)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16.0).fill(Color.white.opacity(0.2)))
                    .padding()
                HStack {
                    Button("", action: changeCurrentGradient)
                        .buttonStyle(CircularGradientButtonStyle(currentGradient: currentGradient))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                    Button("Save") {
                        print("Save")
                    }
                    .foregroundColor(Color.gray)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .background(Color.white)
                    .cornerRadius(16)
                    .font(.title3)
                }
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
