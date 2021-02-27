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
    func saveItem(text: String, on date: Date, gradient: GradientOption) -> Result<Void, Error>
    func saveTag(text: String, isDefault: Bool, defaultGradient: GradientOption) -> Result<Void, Error>
    var tagsPublisher: AnyPublisher<[Tag], LocalStorageError> { get }
    func items(for tag: Tag) -> AnyPublisher<[Item], LocalStorageError>
}

extension Gradient: GradientOption {
    var colorHex: [Int64] {
        return [startColor, endColor]
    }
}

class LocalStorage: LocalStoring, ObservableObject {
    private let persistenceController: PersistenceController

    let tagsPublisher: AnyPublisher<[Tag], LocalStorageError>
    private let notificationPublisher: AnyPublisher <Notification, LocalStorageError>

    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController

        notificationPublisher = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: persistenceController.viewContext)
            .print("notification: ")
            .mapError { _ in LocalStorageError.notificationCenter }
            .share()
            .eraseToAnyPublisher()

        let updatedTags: AnyPublisher<[Tag], LocalStorageError> = notificationPublisher
            .filter { $0.containsChanges(of: Tag.self) }
            .tryMap { _ in
                try persistenceController.viewContext.performFetch(Tag.createFetchRequest())
            }
            .mapError { error in LocalStorageError.fetch(error) }
            .print()
            .eraseToAnyPublisher()
        let _ = Tag.defaultTag(context: persistenceController.viewContext) // initialise tag
        let initialTags: [Tag] = (try? persistenceController.viewContext.performFetch(Tag.createFetchRequest())) ?? []
        let initialTagsPublisher = Just(initialTags)
            .mapError { _ in LocalStorageError.never }
            .eraseToAnyPublisher()
        tagsPublisher = initialTagsPublisher.merge(with: updatedTags)
            .share()
            .eraseToAnyPublisher()

    }

    func saveItem(text: String, on date: Date, gradient: GradientOption) -> Result<Void, Error> {
        do {
            let context = persistenceController.viewContext
            let gradientEntity = Gradient.gradient(from: gradient, context: context)
            try persistenceController.viewContext.createItem(text: text, created: date, gradient: gradientEntity)
            return . success(())
        } catch {
            assertionFailure(error.localizedDescription)
            return .failure(error)
        }
    }

    func saveTag(text: String, isDefault: Bool, defaultGradient: GradientOption) -> Result<Void, Error> {
        do {
            let context = persistenceController.viewContext
            let gradient = Gradient.gradient(from: defaultGradient, context: context)
            try context.createTag(text: text, isDefault: isDefault, defaultGradient: gradient)
            return . success(())
        } catch {
            assertionFailure(error.localizedDescription)
            return .failure(error)
        }
    }

    func items(for tag: Tag) -> AnyPublisher<[Item], LocalStorageError> {
        let fetchgRequest = Item.createFetchRequest()
        fetchgRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Item.tag.id), tag.id.uuidString])

        let updatedItems: AnyPublisher<[Item], LocalStorageError> = notificationPublisher
            .filter { $0.containsChanges(of: Item.self) }
            .tryMap { _ in
                return try self.persistenceController.viewContext.performFetch(fetchgRequest)
            }
            .mapError { error in LocalStorageError.fetch(error) }
            .print()
            .eraseToAnyPublisher()
        let initialItems: [Item] = (try? persistenceController.viewContext.performFetch(fetchgRequest)) ?? []
        let initialItemsPublisher = Just(initialItems)
            .mapError { _ in LocalStorageError.never }
            .eraseToAnyPublisher()
        return initialItemsPublisher.merge(with: updatedItems)
            .share()
            .eraseToAnyPublisher()
    }
}

extension LocalStorage {
    static var preview = LocalStorage(persistenceController: PersistenceController.preview)
}

fileprivate extension Notification {

    func containsChanges<T: NSManagedObject>(of type: T.Type) -> Bool {
        let inserted: Set<T> = insertedObjects()
        let deleted: Set<T> = deletedObjects()
        let updated: Set<T> = updatedObjects()
        return inserted.count > 0 || deleted.count > 0 || updated.count > 0
    }

    func insertedObjects<T: NSManagedObject>() -> Set<T> {
        return userInfo?[NSInsertedObjectsKey] as? Set<T> ?? []
    }

    func deletedObjects<T: NSManagedObject>() -> Set<T> {
        return userInfo?[NSDeletedObjectsKey] as? Set<T> ?? []
    }

    func updatedObjects<T: NSManagedObject>() -> Set<T> {
        return userInfo?[NSUpdatedObjectsKey] as? Set<T> ?? []
    }
}
