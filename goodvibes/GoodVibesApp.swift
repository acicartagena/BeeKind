//Copyright © 2021 acicartagena. All rights reserved.

import SwiftUI

@main
struct GoodVibesApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
