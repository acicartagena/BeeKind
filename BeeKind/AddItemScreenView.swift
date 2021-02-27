// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI

struct AddItemScreenView: View {
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
    let localStoring: LocalStoring

    @State var error: String?
    @Binding var showError: Bool
    @Binding var isPresented: Bool

    var tag: Tag

    init(date: Date, localStoring: LocalStoring, tag: Tag, isPresented: Binding<Bool>) {
        self.tag = tag
        self.date = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let string = dateFormatter.string(from: date)
        print("date: \(string)")
        self.dateString = string
        self.localStoring = localStoring
        _isPresented = isPresented
        _showError = .constant(false)
    }

    var body: some View {
        ZStack {
            currentGradient
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Text(tag.text)
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
                                save()
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
                    .buttonStyle(HexagonGradientButtonStyle(currentGradient: currentGradient))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                Spacer()
            }
        }.alert(isPresented: $showError, content: {
            return Alert(title: Text(error ?? "Something went wrong"), dismissButton: .default(Text("okies")))
        })
    }

    func save() {
        switch localStoring.saveItem(text: itemText, on: date, gradient: availableGradients[currentGradientIndex]) {
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

//struct AddItemScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddItemScreenView(date: Date(), localStoring: LocalStorage.preview, isPresented: .constant(true))
//    }
//}
