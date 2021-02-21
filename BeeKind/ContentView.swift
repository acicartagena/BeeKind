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

    @State private var isAddScreenPresented = false
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
                    Text("Tags")
                        .font(.headline)
                    ForEach(viewModel.tags, id:\.text) { item in
                        Text("\(item.text)")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(TemplateGradients.happyFisher.gradient)
                            .cornerRadius(12.0)
                            .padding(.horizontal, 10)
                    }
                }
                LazyVStack {
                    HStack {
                        Text("Items")
                            .font(.headline)
                        Button("Add item") {
                            self.isAddScreenPresented.toggle()
                        }.sheet(isPresented: $isAddScreenPresented) {
                            AddItemView(date: Date(), localStoring: localStorage, isPresented: $isAddScreenPresented)
                        }
                        .padding()
                    }
                    ForEach(viewModel.items, id:\.text) { item in
                        Text("\(item.text)")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(TemplateGradients.freshMilk.gradient)
                            .cornerRadius(12.0)
                            .padding(.horizontal, 10)
                    }
                }
            }
        }

    }

}

