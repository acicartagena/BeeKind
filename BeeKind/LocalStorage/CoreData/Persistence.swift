// Copyright © 2021 acicartgena. All rights reserved.

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    private let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BeeKind")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        viewContext = container.viewContext
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.created = Date()
            newItem.text = "Item number \(i)"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}

extension NSManagedObjectContext {
    func performSave() throws {
        guard hasChanges else { return }
        var saveError: Error?
        performAndWait { [self] in
            do {
                if hasChanges {
                    try self.save()
                }
            } catch {
                saveError = error
            }
        }
        if let error = saveError {
            throw error
        }
    }

    func performDelete<T: NSManagedObject>(_ object: T) throws {
        var saveError: Error?
        performAndWait { [self] in
            do {
                delete(object)
                if hasChanges {
                    try self.save()
                }
            } catch {
                saveError = error
            }
        }
        if let error = saveError {
            throw error
        }
    }

    func performFetch<T>(_ request: NSFetchRequest<T>) throws -> [T] {
        // TODO: update to an NSManagedObjectContext extension
        var fetchError: Error?
        var result: [T] = []
        self.performAndWait {
            do {
                result = try self.fetch(request)
            } catch {
                assertionFailure(error.localizedDescription)
                fetchError = error
            }
        }
        if let error = fetchError {
            throw error
        }
        return result
    }
}

extension NSManagedObject {
    static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> ()) -> Self {
        guard let object = findOrFetch(in: context, matching: predicate) else {
            var newObject: Self!
            context.performAndWait {
                newObject = Self(context: context)
                configure(newObject)
            }
            return newObject
        }
        return object
    }

    static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            let fetchRequest = Self.fetchRequest()
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchLimit = 1
            let x: Self? = try? context.performFetch(fetchRequest).first as? Self
            return x
        }
        return object
    }


    static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        var materializedObject: Self?
        context.performAndWait {
            for object in context.registeredObjects where !object.isFault {
                guard let result = object as? Self else { continue }
                guard predicate.evaluate(with: result) else { continue }
                materializedObject = result
            }
        }
        return materializedObject
    }
}
