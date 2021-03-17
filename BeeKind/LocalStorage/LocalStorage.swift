// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import CoreData
import Combine

fileprivate let defaultTagIdKey = "DefaultTagId"

enum LocalStorageError: Error {
    case notificationCenter
    case fetch(Error)
    case never
}

protocol LocalStoring {
    var defaultTag: Tag { get }
    var tagsPublisher: AnyPublisher<[Tag], LocalStorageError> { get }
    func tags() -> Result<[Tag], Error>
    func items(for tag: Tag) -> AnyPublisher<[Item], LocalStorageError>
    func createItem(text: String, on date: Date, gradient: GradientOption, tag: Tag) -> Result<Void, Error>
    func update(item: Item, text: String, gradient: GradientOption) -> Result<Void, Error>
    func createTag(text: String, isDefault: Bool, defaultGradient: GradientOption) -> Result<Void, Error>
    func update(tag: Tag, text: String, isDefault: Bool, defaultGradient: GradientOption) -> Result<Void, Error>
}

extension Gradient: GradientOption {
    var colorHex: [Int64] {
        return [startColor, endColor]
    }
}

class LocalStorage: LocalStoring, ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    private let persistenceController: PersistenceController

    let tagsPublisher: AnyPublisher<[Tag], LocalStorageError>
    private let notificationPublisher: AnyPublisher <Notification, LocalStorageError>
    private(set) var defaultTag: Tag {
        didSet {
            userDefaults.setValue(defaultTag.id.uuidString, forKey: defaultTagIdKey)
        }
    }

    private let userDefaults: UserDefaults
    init(persistenceController: PersistenceController = PersistenceController.shared, userDefaults: UserDefaults = UserDefaults.standard) {
        self.persistenceController = persistenceController
        self.userDefaults = userDefaults
        
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

        // initialise tag
        defaultTag = Tag.defaultTag(with: userDefaults.object(forKey: defaultTagIdKey) as? String, context: persistenceController.viewContext)
        userDefaults.setValue(defaultTag.id.uuidString, forKey: defaultTagIdKey)

        let initialTags: [Tag] = (try? persistenceController.viewContext.performFetch(Tag.createFetchRequest())) ?? []
        let initialTagsPublisher = Just(initialTags)
            .mapError { _ in LocalStorageError.never }
            .eraseToAnyPublisher()
        tagsPublisher = initialTagsPublisher.merge(with: updatedTags)
            .share()
            .eraseToAnyPublisher()
    }

    func createItem(text: String, on date: Date, gradient: GradientOption, tag: Tag) -> Result<Void, Error> {
        do {
            let context = persistenceController.viewContext
            let gradientEntity = Gradient.gradient(from: gradient, context: context)
            print("saveItem: gradient: \(gradientEntity)")
            try context.createItem(text: text, created: date, gradient: gradientEntity, tag: tag)
            return . success(())
        } catch {
            assertionFailure(error.localizedDescription)
            return .failure(error)
        }
    }

    func update(item: Item, text: String, gradient: GradientOption) -> Result<Void, Error> {
        do {
            let context = persistenceController.viewContext
            let gradientEntity = Gradient.gradient(from: gradient, context: context)
            try context.update(item: item, text: text, gradient: gradientEntity)
            context.refresh(item, mergeChanges: false)
            return . success(())
        } catch {
            assertionFailure(error.localizedDescription)
            return .failure(error)
        }
    }

    func createTag(text: String, isDefault: Bool, defaultGradient: GradientOption) -> Result<Void, Error> {
        do {
            let context = persistenceController.viewContext
            let gradient = Gradient.gradient(from: defaultGradient, context: context)
            let tag = try context.createTag(text: text, defaultGradient: gradient)
            if isDefault {
                defaultTag = tag
            }
            return . success(())
        } catch {
            assertionFailure(error.localizedDescription)
            return .failure(error)
        }
    }

    func update(tag: Tag, text: String, isDefault: Bool, defaultGradient: GradientOption) -> Result<Void, Error> {
        do {
            let context = persistenceController.viewContext
            let gradient = Gradient.gradient(from: defaultGradient, context: context)
            try context.update(tag: tag, text: text, defaultGradient: gradient)
            if isDefault {
                defaultTag = tag
            }
            return .success(())
        } catch {
            assertionFailure(error.localizedDescription)
            return .failure(error)
        }
    }

    func items(for tag: Tag) -> AnyPublisher<[Item], LocalStorageError> {
        let fetchgRequest = Item.createFetchRequest()
        fetchgRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Item.tag.text), tag.text])

        let updatedItems: AnyPublisher<[Item], LocalStorageError> = notificationPublisher
            .filter { $0.containsChanges(of: Item.self) }
            .tryMap { _ in
                return try self.persistenceController.viewContext.performFetch(fetchgRequest)
            }
            .mapError { error in LocalStorageError.fetch(error) }
            .print("itemsForTag")
            .eraseToAnyPublisher()
        let initialItems: [Item] = (try? persistenceController.viewContext.performFetch(fetchgRequest)) ?? []
        let initialItemsPublisher = Just(initialItems)
            .mapError { _ in LocalStorageError.never }
            .eraseToAnyPublisher()
        return initialItemsPublisher.merge(with: updatedItems)
            .share()
            .eraseToAnyPublisher()
    }

    func tags() -> Result<[Tag], Error> {
        do {
            let tags = try persistenceController.viewContext.performFetch(Tag.createFetchRequest())
            return .success(tags)
        } catch {
            return .failure(error)
        }
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
        guard let set = userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> else { return [] }
        return Set(set.compactMap { $0 as? T })
    }

    func deletedObjects<T: NSManagedObject>() -> Set<T> {
        guard let set = userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> else { return [] }
        return Set(set.compactMap { $0 as? T })
    }

    func updatedObjects<T: NSManagedObject>() -> Set<T> {
        guard let set = userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return [] }
        return Set(set.compactMap { $0 as? T })
    }
}
