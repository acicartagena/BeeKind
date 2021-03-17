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
            print("@angela received tags: \(tags)")
            self.tags = tags
        }.store(in: &cancellables)
    }
}


struct ContentView: View {

    @State private var addItemMode: AddItemScreenView.Mode?
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
                Button("Add Honey") {
                    addItemMode = .add(tag: localStorage.defaultTag, date: Date())
                }.sheet(item: $addItemMode) { mode in
                    AddItemScreenView(mode: mode, localStoring: localStorage)
                }
                .padding()
                ScrollView {
                    LazyVStack {
                        HStack {
                            Text("Honeycombs")
                                .font(.headline)
                            Button("Add honeycomb") {
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
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(tag.defaultGradient.gradient)
                                    .cornerRadius(12.0)
                                    .padding(.horizontal, 10)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }

}

