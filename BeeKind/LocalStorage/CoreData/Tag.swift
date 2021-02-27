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
    @NSManaged public var defaultGradient: Gradient
    @NSManaged public var items: Set<Item>?
}

extension Tag {
    static func create(context: NSManagedObjectContext, text: String, defaultGradient: Gradient) -> Tag {
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.text = text
        tag.defaultGradient = defaultGradient
        return tag
    }

    static func defaultTag(with id: String?, context: NSManagedObjectContext) -> Tag {
        guard let tagId = id else {
            let defaultGradient = Gradient.gradient(from: TemplateGradients.soda, context: context)
            return Tag.create(context: context, text: "I am grateful for", defaultGradient: defaultGradient)
        }
        let request = createFetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Tag.id), tagId])
        do {
            let tags = try context.performFetch(request)
            if let tag = tags.first {
                return tag
            }
        } catch {
            print(error)
        }

        let defaultGradient = Gradient.gradient(from: TemplateGradients.soda, context: context)
        return Tag.create(context: context, text: "I am grateful for", defaultGradient: defaultGradient)
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createTag(text: String, defaultGradient: Gradient) throws -> Tag {
        let item = Tag.create(context: self, text: text, defaultGradient: defaultGradient)
        try performSave()
        return item
    }
}
