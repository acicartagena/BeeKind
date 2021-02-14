//Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import CoreData

@objc(ItemLocal)
class ItemLocal: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ItemLocal> {
        return NSFetchRequest<ItemLocal>(entityName: "ItemLocal")
    }

    @NSManaged public var text: String
    @NSManaged public var created: Date
}

extension ItemLocal {
    static func create(context: NSManagedObjectContext, text: String, created: Date) -> ItemLocal {
        let item = ItemLocal(context: context)
        item.text = text
        item.created = created
        return item
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createItemLocal(text: String, created: Date) throws -> ItemLocal {
        let item = ItemLocal.create(context: self, text: text, created: created)
        try performSave()
        return item
    }
}
