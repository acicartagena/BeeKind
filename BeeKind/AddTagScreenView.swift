// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI

struct AddTagScreenView: View {
    enum Mode: Identifiable {
        var id: String {
            switch self {
            case .add: return "add"
            case let .update(tag): return "update:\(tag.text)"
            }
        }

        case add
        case update(Tag)
    }

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
    @State var isDefault = false
    @Environment(\.presentationMode) var presentationMode

    private let mode: Mode
    @State var showDeleteButton: Bool = false

    init(mode: Mode, localStoring: LocalStoring) {
        self.localStoring = localStoring
        _showError = .constant(false)
        self.mode = mode
        switch mode {
        case .update(let tag):
            if let index = availableGradients.firstIndex(where: { $0.name.lowercased() == tag.defaultGradient.name.lowercased() })  {
                _currentGradientIndex = State(initialValue: index)
            }
            _tagPromptText = State(initialValue: tag.text)
            _isDefault = State(initialValue: localStoring.defaultTag == tag)
            _showDeleteButton = State(initialValue: true)
        case .add: break
        }
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
                    if showDeleteButton {
                        Button("Delete") {
                            delete()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .background(availableGradients[currentGradientIndex].colors.first)
                        .cornerRadius(28)
                        .font(.title3)
                        .shadow(radius: 0.8)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 8))
                    }
                    Button("Save") {
                        save()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(availableGradients[currentGradientIndex].colors.first)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .background(Color.white)
                    .cornerRadius(28)
                    .font(.title3)
                    .shadow(radius: 0.8)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 8))

                    Spacer()
                }.padding()
            }
        }.alert(isPresented: $showError, content: {
            return Alert(title: Text(error ?? "Something went wrong"), dismissButton: .default(Text("okies")))
        })
    }

    func save() {
        switch mode {
        case .add: addTag()
        case .update(let tag): update(tag: tag)
        }

    }

    func addTag() {
        let result = localStoring.createTag(text: tagPromptText, isDefault: isDefault, defaultGradient: availableGradients[currentGradientIndex])
        handleOperation(result: result)
    }

    func update(tag: Tag) {
        let result = localStoring.update(tag: tag, text: tagPromptText, isDefault: isDefault, defaultGradient: availableGradients[currentGradientIndex])
        handleOperation(result: result)
    }

    func delete() {
        guard case let .update(tag) = mode else { return }
        let result = localStoring.delete(tag: tag)
        handleOperation(result: result)
    }

    func handleOperation(result: Result<Void, Error>) {
        switch result {
        case .success: presentationMode.wrappedValue.dismiss()
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
        AddTagScreenView(mode: .add, localStoring: LocalStorage.preview)
    }
}
