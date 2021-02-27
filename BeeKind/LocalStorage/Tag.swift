// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import CoreData

@objc(Tag)
class Tag: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var text: String
    @NSManaged public var id: UUID
    @NSManaged public var isDefault: Bool
    @NSManaged public var defaultGradient: Gradient
    @NSManaged public var items: Set<Item>?
}

extension Tag {
    static func create(context: NSManagedObjectContext, text: String, isDefault: Bool, defaultGradient: Gradient) -> Tag {
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.text = text
        tag.isDefault = isDefault
        tag.defaultGradient = defaultGradient
        return tag
    }

    static func defaultTag(context: NSManagedObjectContext) -> Tag {
        let request = createFetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %d", argumentArray: [#keyPath(Tag.isDefault), true])
        do {
            let tags = try context.performFetch(request)
            if let tag = tags.first {
                return tag
            }
        } catch {
            print(error)
        }
        let defaultGradient = Gradient.gradient(from: TemplateGradients.soda, context: context)
        return Tag.create(context: context, text: "I am grateful for", isDefault: true, defaultGradient: defaultGradient)
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createTag(text: String, isDefault: Bool, defaultGradient: Gradient) throws -> Tag {
        let item = Tag.create(context: self, text: text, isDefault: isDefault, defaultGradient: defaultGradient)
        try performSave()
        return item
    }
}
