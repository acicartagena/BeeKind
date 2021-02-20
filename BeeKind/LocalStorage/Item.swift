//Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import CoreData

@objc(Item)
class Item: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var text: String
    @NSManaged public var created: Date
}

extension Item {
    static func create(context: NSManagedObjectContext, text: String, created: Date) -> Item {
        let item = Item(context: context)
        item.text = text
        item.created = created
        return item
    }

    var fetchRequest: NSFetchRequest<Item> {
        Item.createFetchRequest()
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createItem(text: String, created: Date) throws -> Item {
        let item = Item.create(context: self, text: text, created: created)
        try performSave()
        return item
    }
}
