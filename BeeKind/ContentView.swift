//Copyright © 2021 acicartagena. All rights reserved.

import SwiftUI
import CoreData
import Combine

class ContentViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var items: [ItemLocal] = [] {
        didSet {
            print("items: \(items)")
        }
    }
    init(localStorage: LocalStoring) {
        localStorage.itemsPublisher.sink { _ in
            print("complete")
        } receiveValue: { items in
            self.items = items
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
            Button("Add item") {
                self.isAddScreenPresented.toggle()
            }.sheet(isPresented: $isAddScreenPresented) {
                AddItemView(date: Date(), localStoring: localStorage, isPresented: $isAddScreenPresented)
            }
            .padding()
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.items, id:\.text) { item in
                        Text("\(item.text)")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(12.0)
                            .padding(.horizontal, 10)
                    }
                }
            }
        }

    }

}

