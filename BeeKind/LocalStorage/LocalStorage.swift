//Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import CoreData

protocol LocalStoring {
    func saveItem(text: String, on date: Date) -> Result<Void, Error>
}

class LocalStorage: LocalStoring, ObservableObject {
    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController
    }

    func saveItem(text: String, on date: Date) -> Result<Void, Error> {
        do {
            try persistenceController.viewContext.createItemLocal(text: text, created: date)
            return . success(())
        } catch {
            assertionFailure(error.localizedDescription)
            return .failure(error)
        }
    }

}

extension LocalStorage {
    static var preview = LocalStorage(persistenceController: PersistenceController.preview)
}
