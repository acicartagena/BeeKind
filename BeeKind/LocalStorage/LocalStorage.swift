// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import CoreData
import Combine

enum LocalStorageError: Error {
    case notificationCenter
    case fetch(Error)
    case never
}

protocol LocalStoring {
    func saveItem(text: String, on date: Date) -> Result<Void, Error>
    var itemsPublisher: AnyPublisher<[Item], LocalStorageError> { get }
}

class LocalStorage: LocalStoring, ObservableObject {
    private let persistenceController: PersistenceController
    let itemsPublisher: AnyPublisher<[Item], LocalStorageError>

    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController

        let notificationPublisher = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: persistenceController.viewContext)
            .mapError { _ in LocalStorageError.notificationCenter }
            .tryMap { _ in
                try persistenceController.viewContext.performFetch(request: Item.createFetchRequest())
            }
            .mapError { error in LocalStorageError.fetch(error) }
            .print()
            .eraseToAnyPublisher()

        let initialItems: [Item] = (try? persistenceController.viewContext.performFetch(request: Item.createFetchRequest())) ?? []

                                            //.fetch(Item.createFetchRequest())) ?? []

        let initialPublisher = Just(initialItems)
            .mapError { _ in LocalStorageError.never }
            .eraseToAnyPublisher()

        itemsPublisher = Publishers.Merge(initialPublisher, notificationPublisher).eraseToAnyPublisher()

    }

    func saveItem(text: String, on date: Date) -> Result<Void, Error> {
        do {
            try persistenceController.viewContext.createItem(text: text, created: date)
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
