//Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import CoreData

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
    func createItemLocal(text: String, created: Date) -> ItemLocal {
        ItemLocal.create(context: self, text: text, created: created)
    }
}
