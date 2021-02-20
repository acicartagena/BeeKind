// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import CoreData

@objc(Item)
class Item: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var text: String
    @NSManaged public var created: Date
    @NSManaged public var tag: Tag
    @NSManaged public var id: UUID
}

extension Item {
    static func create(context: NSManagedObjectContext, text: String, created: Date, tag: Tag) -> Item {
        let item = Item(context: context)
        item.id = UUID()
        item.text = text
        item.created = created
        item.tag = tag
        return item
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createItem(text: String, created: Date, tag: Tag? = nil) throws -> Item {
        let itemTag = tag ?? Tag.defaultTag(context: self)
        let item = Item.create(context: self, text: text, created: created, tag: itemTag)
        try performSave()
        return item
    }
}
