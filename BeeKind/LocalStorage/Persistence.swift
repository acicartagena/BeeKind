//Copyright © 2021 acicartagena. All rights reserved.

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
            let newItem = ItemLocal(context: viewContext)
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
        perform { [self] in
            do {
                try self.save()
            } catch {
                saveError = error
            }
        }
        if let error = saveError {
            throw error
        }
    }

    func performFetch<T: NSManagedObject>(request: NSFetchRequest<T>) throws -> [T]  {
        var fetchError: Error?
        var result: [T] = []
        perform {
            do {
                result = try self.fetch(request)
            } catch {
                fetchError = error
            }
        }
        if let error = fetchError {
            throw error
        }
        return result
    }

}
