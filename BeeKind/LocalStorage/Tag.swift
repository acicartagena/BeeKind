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
    @NSManaged public var isDefault: Bool
}

extension Tag {
    static func create(context: NSManagedObjectContext, text: String, created: Date, isDefault: Bool) -> Tag {
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.text = text
        tag.created = created
        tag.isDefault = isDefault
        return tag
    }

    static func defaultTag(context: NSManagedObjectContext) -> Tag {
        let request = createFetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "isDefault == %d", [true])
        do {
            let tags = try context.performFetch(request: request)
            if let tag = tags.first {
                return tag
            }
        } catch {
            print(error)
        }
        return Tag.create(context: context, text: "I am grateful for", created: Date(), isDefault: true)
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createTag(text: String, created: Date, isDefault: Bool) throws -> Tag {
        let item = Tag.create(context: self, text: text, created: created, isDefault: isDefault)
        try performSave()
        return item
    }
}
