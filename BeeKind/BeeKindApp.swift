// Copyright © 2021 acicartgena. All rights reserved.

import SwiftUI

@main
struct BeeKindApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(localStorage: LocalStorage())
        }
    }
}
