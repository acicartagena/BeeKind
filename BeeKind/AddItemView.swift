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

    let date: Date
    let dateString: String

    init(date: Date) {
        self.date = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let string = dateFormatter.string(from: date)
        print("date: \(string)")
        self.dateString = string
    }

    var body: some View {
        ZStack {
            currentGradient
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Text("I'm grateful for")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .italic()
                    .shadow(radius: 0.8)
                    .padding()
                ZStack {
                    RoundedRectangle(cornerRadius: 16.0).fill(Color.white.opacity(0.2))
                    VStack {
                        HStack {
                            Text(dateString)
                                .font(.title2)
                                .foregroundColor(Color.white)
                                .bold()
                                .shadow(radius: 0.8)
                            Spacer()
                            Text(itemTextRemainingCharacters)
                                .foregroundColor(Color.black)
                                .italic()
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 20))
                        TextView(text: $itemText, maxCharacterCount: itemTextMaxCharacters)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        HStack {
                            Spacer()
                            Button("Save") {
                                print("Save")
                            }
                            .foregroundColor(Color.gray)
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .background(Color.white)
                            .cornerRadius(16)
                            .font(.title3)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 8))
                        }
                    }
                }
                .padding()
                Button("", action: changeCurrentGradient)
                    .buttonStyle(CircularGradientButtonStyle(currentGradient: currentGradient))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
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
        AddItemView(date: Date())
    }
}
