//Copyright © 2021 acicartagena. All rights reserved.

import SwiftUI

@main
struct goodvibesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
