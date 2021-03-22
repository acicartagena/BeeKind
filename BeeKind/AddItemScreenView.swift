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
    enum Mode: Identifiable {
        var id: String {
            switch self {
            case let .add(tag, date): return "add:\(tag.text)+\(date)"
            case let .update(item): return "update:\(item.text)"
            }
        }

        case add(tag: Tag, date: Date)
        case update(Item)
    }

    private let availableGradients: [GradientOption] = TemplateGradients.availableGradients
    @State private var currentGradientIndex: Int = 0
    private var currentGradient: GradientOption {
        availableGradients[currentGradientIndex]
    }
    private var currentLinearGradient: LinearGradient {
        availableGradients[currentGradientIndex].gradient
    }

    @State private var itemText: String = ""
    private var itemTextMaxCharacters = 140
    private var itemTextRemainingCharacters: String {
        "\(itemTextMaxCharacters - itemText.count)/\(itemTextMaxCharacters)"
    }

    private let date: Date
    private var dateString: String
    private let localStoring: LocalStoring

    private let mode: Mode

    @State private var error: String?
    @State private var showError: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showTagPicker: Bool = false

    @ObservedObject private var viewModel: AddItemViewModel
    @State private var tagSelection: Int = 0

    @State private var tag: Tag
    @State private var showDeleteButton: Bool = false

    init(mode: Mode, localStoring: LocalStoring) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        self.localStoring = localStoring
        viewModel = AddItemViewModel(localStorage: localStoring)
        self.mode = mode
        switch mode {
        case .update(let item):
            _tag = State(initialValue: item.tag)
            if let index = availableGradients.firstIndex(where: { $0.name.lowercased() == item.gradient.name.lowercased() })  {
                _currentGradientIndex = State(initialValue: index)
            }
            self.date = item.created
            let string = dateFormatter.string(from: date)
            self.dateString = string
            _itemText = State(initialValue: item.text)
            self.dateString = dateFormatter.string(from: item.created)
            _showDeleteButton = State(initialValue: true)
        case .add(let tag, let date):
            _tag = State(initialValue: tag)
            self.date = date
            let string = dateFormatter.string(from: date)
            self.dateString = string
            if let index = availableGradients.firstIndex(where: { $0.name.lowercased() == tag.defaultGradient.name.lowercased() })  {
                _currentGradientIndex = State(initialValue: index)
            }
        }
    }

    var body: some View {
        ZStack {
            currentLinearGradient
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Button {
                    showTagPicker = true
                } label: {
                    Text(tag.text)
                        .foregroundColor(currentGradient.endColor)
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
                            if showDeleteButton {
                                Button("Delete") {
                                    delete()
                                }
                                .foregroundColor(Color.white)
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .background(currentGradient.endColor)
                                .cornerRadius(28)
                                .font(.title3)
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0))
                                .shadow(radius: 0.8)
                            }

                            Spacer()
                            Button("Save") {
                                save()
                            }
                            .foregroundColor(currentGradient.endColor)
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
                    .buttonStyle(HexagonGradientButtonStyle(currentGradient: currentLinearGradient))
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
                                    .background(Color(hex: viewModel.tags[index].defaultGradient.startColorHex))
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
        switch mode {
        case .add: addItem()
        case .update(let item): update(item: item)
        }
    }

    func addItem() {
        let result = localStoring.createItem(text: itemText, on: date, gradient: availableGradients[currentGradientIndex], tag: tag)
        handleOperation(result: result)
    }

    func update(item: Item) {
        let result = localStoring.update(item: item, text: itemText, gradient: availableGradients[currentGradientIndex])
        handleOperation(result: result)
    }

    func delete() {
        guard case let .update(tag) = mode else { return }
        let result = localStoring.delete(tag)
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

//struct AddItemScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddItemScreenView(date: Date(), localStoring: LocalStorage.preview, isPresented: .constant(true))
//    }
//}
