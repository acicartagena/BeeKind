// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI
import Combine

class TagItemsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var items: [Item] = []

    let tagText: String

    init(localStorage: LocalStoring, tag: Tag) {
        tagText = tag.text
        localStorage.items(for: tag).sink { _ in
            print("items complete")
        } receiveValue: { items in
            print("@angela tag: \(tag.text) received items: \(items)")
            self.items = items
        }.store(in: &cancellables)
    }
}

struct TagItemsScreenView: View {
    enum Sheet: Identifiable {
        var id: String {
            switch self {
            case .addEditItem: return "addEditItem"
            case .editTag: return "editTag"
            }
        }

        case addEditItem(AddItemScreenView.Mode)
        case editTag

        var addEditItemMode: AddItemScreenView.Mode? {
            guard case let .addEditItem(mode) = self else { return nil }
            return mode
        }
    }

    @ObservedObject private var viewModel: TagItemsViewModel
    @State private var isAddOrUpdateItemScreenPresented = false
    @State private var presentSheet: Sheet? = nil
    @State private var selectedItemMode: AddItemScreenView.Mode? = nil
    private let localStorage: LocalStoring
    private let tag: Tag

    init(localStorage: LocalStoring, tag: Tag) {
        self.tag = tag
        self.localStorage = localStorage
        viewModel = TagItemsViewModel(localStorage: localStorage, tag: tag)
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(viewModel.tagText)
                .font(.largeTitle)
                .bold()
                .italic()
                .shadow(radius: 0.8)
                .padding()
            Button("Add honey") {
                addHoney()
            }
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.items, id:\.id) { item in
                        Button {
                            select(item: item)
                        } label: {
                            Text("\(item.text)")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(item.gradient.gradient)
                                .cornerRadius(12.0)
                                .padding(.horizontal, 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

        }
        .sheet(item: $presentSheet) { sheet in
            if sheet.id == "addEditItem" {
                AddItemScreenView(mode: sheet.addEditItemMode!, localStoring: localStorage)
            } else {
                AddTagScreenView(mode: .update(tag), localStoring: localStorage)
            }
        }
        .navigationBarItems(trailing: Button("Edit Honeycomb", action: {
            presentSheet = .editTag
        }))
    }

    func addHoney() {
        presentSheet = .addEditItem(.add(tag: tag, date: Date()))
    }

    func select(item: Item) {
        presentSheet = .addEditItem(.update(item))
    }

    func delete(at offsets: IndexSet) {
        print("delete: \(offsets)")
    }
}
//
//struct TagItemsScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TagItemsScreenView(localStorage: <#LocalStoring#>, tag: Tag.defaultTag(context: ))
//    }
//}
