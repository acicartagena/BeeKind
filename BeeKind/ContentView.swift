// Copyright © 2021 acicartgena. All rights reserved.

import SwiftUI
import CoreData
import Combine

class ContentViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var items: [Item] = []

    @Published var tags: [Tag] = []

    init(localStorage: LocalStoring) {
        localStorage.itemsPublisher.sink { _ in
            print("items complete")
        } receiveValue: { items in
            print("received items: \(items)")
            self.items = items
        }.store(in: &cancellables)


        localStorage.tagsPublisher.sink { _ in
            print("tags complete")
        } receiveValue: { tags in
            print("received tags: \(tags)")
            self.tags = tags
        }.store(in: &cancellables)
    }
}


struct ContentView: View {

    @State private var isAddItemScreenPresented = false
    @State private var isAddTagScreenPresented = false
    private let localStorage: LocalStoring
    @ObservedObject private var viewModel: ContentViewModel

    init(localStorage: LocalStoring) {
        self.localStorage = localStorage
        viewModel = ContentViewModel(localStorage: localStorage)
    }

    var body: some View {
        VStack {
            Text("Bee Kind")
                .font(.largeTitle)
                .padding()
            ScrollView {
                LazyVStack {
                    HStack {
                        Text("Tags")
                            .font(.headline)
                        Button("Add tag") {
                            self.isAddTagScreenPresented.toggle()
                        }.sheet(isPresented: $isAddTagScreenPresented) {
                            AddTagView(localStoring: localStorage, isPresented: $isAddTagScreenPresented)
                        }
                        .padding()
                    }
                    ForEach(viewModel.tags, id:\.id) { tag in
                        Text("\(tag.text)")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(tag.defaultGradient.gradient)
                            .cornerRadius(12.0)
                            .padding(.horizontal, 10)
                    }
                }
                LazyVStack {
                    HStack {
                        Text("Items")
                            .font(.headline)
                        Button("Add item") {
                            self.isAddItemScreenPresented.toggle()
                        }.sheet(isPresented: $isAddItemScreenPresented) {
                            AddItemView(date: Date(), localStoring: localStorage, isPresented: $isAddItemScreenPresented)
                        }
                        .padding()
                    }
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

}

