//Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import CoreData
import Combine

enum LocalStorageError: Error {
    case notificationCenter
    case fetch(Error)
}

protocol LocalStoring {
    func saveItem(text: String, on date: Date) -> Result<Void, Error>
    var itemsPublisher: AnyPublisher<[ItemLocal], LocalStorageError> { get }
}

class LocalStorage: LocalStoring, ObservableObject {
    private let persistenceController: PersistenceController
    let itemsPublisher: AnyPublisher<[ItemLocal], LocalStorageError>

    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController

        let notification = NSManagedObjectContext.didMergeChangesObjectIDsNotification
        itemsPublisher = NotificationCenter.default.publisher(for: notification, object: persistenceController.viewContext)
            .mapError { _ in LocalStorageError.notificationCenter }
            .tryMap { _ in
                try persistenceController.viewContext.performFetch(request: ItemLocal.createFetchRequest())
            }
            .mapError { error in LocalStorageError.fetch(error) }
            .print()
            .eraseToAnyPublisher()
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
