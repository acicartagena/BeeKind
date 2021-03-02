// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI

struct AddTagScreenView: View {
    let availableGradients: [GradientOption] = TemplateGradients.availableGradients
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
    @State var isDefault = false

    init(localStoring: LocalStoring, isPresented: Binding<Bool>) {
        self.localStoring = localStoring
        _isPresented = isPresented
        _showError = .constant(false)
    }

    var body: some View {
        ZStack {
            currentGradient
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                HStack (alignment: .center){
                    Spacer()
                    Text(tagPromptRemainingCharacters)
                        .foregroundColor(Color.white)
                        .italic()
                }
                .padding()
                Text("Text:")
                    .font(.title)
                    .foregroundColor(Color.white)
                    .bold()
                    .italic()
                    .shadow(radius: 1.5)
                    .padding()
                TextView(text: $tagPromptText, maxCharacterCount: tagPromptMaxCharacters, textStyle: UIFont.TextStyle.largeTitle)
                    .shadow(radius: 0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    .padding()
                Toggle(isOn: $isDefault) {
                    Text("Default HoneyComb:")
                        .font(.title)
                        .foregroundColor(Color.white)
                        .bold()
                        .italic()
                        .shadow(radius: 1.5)
                }
                .padding()
                HStack {
                    Text("Gradient:")
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
                HStack {
                    Spacer()
                    Button("Save") {
                        save()
                    }
                    .foregroundColor(availableGradients[currentGradientIndex].colors.first)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .background(Color.white)
                    .cornerRadius(28)
                    .font(.title3)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 8))
                    .shadow(radius: 0.8)
                    Spacer()
                }.padding()
            }
        }.alert(isPresented: $showError, content: {
            return Alert(title: Text(error ?? "Something went wrong"), dismissButton: .default(Text("okies")))
        })
    }

    func save() {
        switch localStoring.saveTag(text: tagPromptText, isDefault: isDefault, defaultGradient: availableGradients[currentGradientIndex]) {
        case .success: isPresented = false
        case .failure(let saveError):
            showError = true
            error = saveError.localizedDescription
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

struct AddTagScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AddTagScreenView(localStoring: LocalStorage.preview, isPresented: .constant(true))
    }
}
