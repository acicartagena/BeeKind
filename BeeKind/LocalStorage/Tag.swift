// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import CoreData

@objc(Tag)
class Tag: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var text: String
    @NSManaged public var created: Date
    @NSManaged public var items: Set<Item>?
    @NSManaged public var id: UUID
}

extension Tag {
    static func create(context: NSManagedObjectContext, text: String, created: Date) -> Tag {
        let item = Tag(context: context)
        item.text = text
        item.created = created
        return item
    }

    var fetchRequest: NSFetchRequest<Tag> {
        Tag.createFetchRequest()
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createTag(text: String, created: Date) throws -> Tag {
        let item = Tag.create(context: self, text: text, created: created)
        try performSave()
        return item
    }
}
