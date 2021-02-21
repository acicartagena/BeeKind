// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI

struct AddTagView: View {
    let availableGradients: [GradientOption] = TemplateGradients.allCases
    @State var currentGradientIndex: Int = 0
    var currentGradient: LinearGradient {
        availableGradients[currentGradientIndex].gradient
    }

    @State var tagPromptText: String = ""
    var tagPromptMaxCharacters = 60
    var tagPromptRemainingCharacters: String {
        "\(tagPromptMaxCharacters - tagPromptText.count)/\(tagPromptMaxCharacters)"
    }

    let localStoring: LocalStoring

    @State var error: String?
    @Binding var showError: Bool
    @Binding var isPresented: Bool

    init(localStoring: LocalStoring, isPresented: Binding<Bool>) {
        self.localStoring = localStoring
        _isPresented = isPresented
        _showError = .constant(false)
    }

    var body: some View {
        ZStack {
            currentGradient
                .edgesIgnoringSafeArea(.all)
            RotatedShape(shape: Hexagon(),
                                     angle: Angle(degrees: 90),
                                     anchor: .center)
                .stroke(Color.white.opacity(0.10), lineWidth: 5)
                .background(Color.white.opacity(0.20))
                .clipShape(RotatedShape(shape: Hexagon(),
                                        angle: Angle(degrees: 90),
                                        anchor: .center))
                .padding()
            VStack(alignment: .leading) {
                Spacer()
                HStack{
                    Text("Prompt:")
                        .foregroundColor(Color.white)
                    Spacer()
                    Text(tagPromptRemainingCharacters)
                        .foregroundColor(Color.white)
                        .italic()
                    Spacer()
                }
                .padding()
                TextView(text: $tagPromptText, maxCharacterCount: tagPromptMaxCharacters)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    .padding()
                HStack {
                    Text("Default Gradient")
                        .font(.title)
                        .foregroundColor(Color.white)
                        .bold()
                        .italic()
                        .shadow(radius: 1.5)
                        .padding()
                    Button("", action: changeCurrentGradient)
                        .buttonStyle(HexagonGradientButtonStyle(currentGradient: currentGradient))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                }
                Spacer()
            }
        }.alert(isPresented: $showError, content: {
            return Alert(title: Text(error ?? "Something went wrong"), dismissButton: .default(Text("okies")))
        })
    }

    func save() {
//        switch localStoring.saveItem(text: itemText, on: date) {
//        case .success: isPresented = false
//        case .failure(let saveError):
//            showError = true
//            error = saveError.localizedDescription
//        }
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

struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        AddTagView(localStoring: LocalStorage.preview, isPresented: .constant(true))
    }
}
