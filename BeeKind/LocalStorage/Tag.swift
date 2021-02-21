// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import CoreData

@objc(Tag)
class Tag: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var label: String
    @NSManaged public var prompt: String
    @NSManaged public var items: Set<Item>?
    @NSManaged public var id: UUID
    @NSManaged public var isDefault: Bool
}

extension Tag {
    static func create(context: NSManagedObjectContext, prompt: String, label: String, isDefault: Bool) -> Tag {
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.prompt = prompt
        tag.label = label
        tag.isDefault = isDefault
        return tag
    }

    static func defaultTag(context: NSManagedObjectContext) -> Tag {
        let request = createFetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %d", argumentArray: [#keyPath(Tag.isDefault), true])
        do {
            let tags = try context.performFetch(request: request)
            if let tag = tags.first {
                return tag
            }
        } catch {
            print(error)
        }
        return Tag.create(context: context, prompt: "I am grateful for", label: "grateful", isDefault: true)
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createTag(prompt: String, label: String, isDefault: Bool) throws -> Tag {
        let item = Tag.create(context: self, prompt: prompt, label: label, isDefault: isDefault)
        try performSave()
        return item
    }
}
