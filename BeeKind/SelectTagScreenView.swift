// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import SwiftUI
import Combine

class SelectTagViewModel: ObservableObject {
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

struct SelectTagScreenView: View {

    @ObservedObject private var viewModel: SelectTagViewModel
    @State var selection: Int = 0

    init(localStorage: LocalStoring) {
        viewModel = SelectTagViewModel(localStorage: localStorage)
    }

    var body: some View {
        Picker(selection: $selection, label: Text("Tag")) {
            ForEach(0 ..< viewModel.tags.count) { index in
                Text(self.viewModel.tags[index].text)
            }
        }.pickerStyle(WheelPickerStyle())
    }
}
