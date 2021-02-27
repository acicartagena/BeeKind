// Copyright © 2021 acicartgena. All rights reserved.

import SwiftUI
import CoreData
import Combine
import UIKit

class ContentViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var tags: [Tag] = []

    init(localStorage: LocalStoring) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance

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
        NavigationView{
            VStack {
                Text("Bee Kind")
                    .font(.largeTitle)
                    .padding()
                Button("Add item") {
                    self.isAddItemScreenPresented.toggle()
                }.sheet(isPresented: $isAddItemScreenPresented) {
                    AddItemScreenView(date: Date(), localStoring: localStorage, tag: localStorage.defaultTag, isPresented: $isAddItemScreenPresented)
                }
                .padding()
                ScrollView {
                    LazyVStack {
                        HStack {
                            Text("Tags")
                                .font(.headline)
                            Button("Add tag") {
                                self.isAddTagScreenPresented.toggle()
                            }.sheet(isPresented: $isAddTagScreenPresented) {
                                AddTagScreenView(localStoring: localStorage, isPresented: $isAddTagScreenPresented)
                            }
                            .padding()
                        }
                        ForEach(viewModel.tags, id:\.id) { tag in
                            NavigationLink(destination: TagItemsScreenView(localStorage: localStorage, tag: tag)) {
                                Text("\(tag.text)")
                                    .font(.title)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(tag.defaultGradient.gradient)
                            .cornerRadius(12.0)
                            .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
    }

}

