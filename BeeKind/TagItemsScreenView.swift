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

    @ObservedObject private var viewModel: TagItemsViewModel
    @State private var isAddItemScreenPresented = false
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
                self.isAddItemScreenPresented.toggle()
            }.sheet(isPresented: $isAddItemScreenPresented) {
                AddItemScreenView(date: Date(), localStoring: localStorage, tag: tag, isPresented: $isAddItemScreenPresented)
            }
        }
        ScrollView {
            LazyVStack {
                ForEach(viewModel.items, id:\.id) { item in
                    Text("\(item.text)")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(item.gradient.gradient)
                        .cornerRadius(12.0)
                        .padding(.horizontal, 10)
                }
            }
        }
    }
}
//
//struct TagItemsScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TagItemsScreenView(localStorage: <#LocalStoring#>, tag: Tag.defaultTag(context: ))
//    }
//}
