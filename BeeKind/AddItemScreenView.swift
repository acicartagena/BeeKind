// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI
import Combine

class AddItemViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var tags: [Tag] = []

    init(localStorage: LocalStoring) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance

        if case let .success(initialTags) = localStorage.tags() {
            tags = initialTags
        }
        localStorage.tagsPublisher.sink { _ in
            print("tags complete")
        } receiveValue: { tags in
            print("@angela received tags: \(tags)")
            self.tags = tags
        }.store(in: &cancellables)
    }
}

struct AddItemScreenView: View {
    let availableGradients: [GradientOption] = TemplateGradients.availableGradients
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
    @State var showError: Bool = false
    @Binding var isPresented: Bool
    @State var showTagPicker: Bool = false

    @ObservedObject private var viewModel: AddItemViewModel
    @State var tagSelection: Int = 0

    @State var tag: Tag

    init(date: Date, localStoring: LocalStoring, tag: Tag, isPresented: Binding<Bool>) {
        self.date = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let string = dateFormatter.string(from: date)
        print("date: \(string)")
        self.dateString = string
        self.localStoring = localStoring
        _isPresented = isPresented
        viewModel = AddItemViewModel(localStorage: localStoring)
        _tag = State(initialValue: tag)
        if let index = availableGradients.firstIndex(where: { $0.name.lowercased() == tag.defaultGradient.name.lowercased() })  {
            _currentGradientIndex = State(initialValue: index)
        }
    }

    var body: some View {
        ZStack {
            currentGradient
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Button {
                    showTagPicker = true
                } label: {
                    Text(tag.text)
                        .foregroundColor(Color(hex:tag.defaultGradient.endColor))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(36.0)
                        .shadow(radius: 0.8)
                }
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
                            .foregroundColor(Color(hex:tag.defaultGradient.endColor))
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .background(Color.white)
                            .cornerRadius(28)
                            .font(.title3)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 8))
                            .shadow(radius: 0.8)
                        }
                    }
                }
                .padding()
                Button("", action: changeCurrentGradient)
                    .buttonStyle(HexagonGradientButtonStyle(currentGradient: currentGradient))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                Spacer()
            }
            if showTagPicker {
                ZStack {
                    Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                    VStack {
                        Spacer()
                        Text("Select Honeycomb")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                            .italic()
                            .padding()
                        ForEach(0 ..< viewModel.tags.count) { index in
                            Button {
                                showTagPicker = false
                                tag = viewModel.tags[index]
                                if let index = availableGradients.firstIndex(where: { $0.name.lowercased() == tag.defaultGradient.name.lowercased() })  {
                                    self.currentGradientIndex = index
                                }
                            } label: {
                                Text(self.viewModel.tags[index].text)
                                    .shadow(radius: 0.1)
                                    .padding()
                                    .font(.title3)
                                    .foregroundColor(Color.white)
                                    .background(Color(hex: viewModel.tags[index].defaultGradient.startColor))
                                    .cornerRadius(32.0)

                            }
                            .padding()
                        }
                        Button("Cancel") {
                            showTagPicker = false
                        }.foregroundColor(.white)
                        .padding()
                        Spacer()
                    }
                }

            }
        }
        .alert(isPresented: $showError) {
            return Alert(title: Text(error ?? "Something went wrong"), dismissButton: .default(Text("okies")))
        }
    }

    func save() {
        switch localStoring.saveItem(text: itemText, on: date, gradient: availableGradients[currentGradientIndex], tag: tag) {
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
