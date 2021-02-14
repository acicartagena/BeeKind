//Copyright © 2021 acicartagena. All rights reserved.

import SwiftUI
import CoreData

struct ContentView: View {

    @State private var isAddScreenPresented = false

    var body: some View {
        Button("Add item") {
            self.isAddScreenPresented.toggle()
        }.sheet(isPresented: $isAddScreenPresented) {
            AddItemView(date: Date())
        }
    }

}

