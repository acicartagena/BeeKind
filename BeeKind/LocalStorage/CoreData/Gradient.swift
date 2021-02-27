// Copyright © 2021 acicartgena. All rights reserved.

import Foundation
import CoreData

@objc(Gradient)
class Gradient: NSManagedObject {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Gradient> {
        return NSFetchRequest<Gradient>(entityName: "Gradient")
    }

    @NSManaged public var name: String
    @NSManaged public var startColor: Int64
    @NSManaged public var endColor: Int64
}

extension Gradient {
    static func create(context: NSManagedObjectContext, name: String, startColor: Int64, endColor: Int64) -> Gradient {
        let gradient = Gradient(context: context)
        gradient.name = name
        gradient.startColor = startColor
        gradient.endColor = endColor
        return gradient
    }

    static func findOrCreate(context: NSManagedObjectContext, name: String, startColor: Int64, endColor: Int64) -> Gradient {
        let predicate = NSPredicate(format: " %K == %@ OR ( %K == %i AND %K == %i)", argumentArray: [#keyPath(Gradient.name), name, #keyPath(Gradient.startColor), startColor, #keyPath(Gradient.endColor), endColor])
        let gradient = Gradient.findOrCreate(in: context, matching: predicate) { entity in
            guard let gradient = entity as? Gradient else { return }
            gradient.name = name
            gradient.startColor = startColor
            gradient.endColor = endColor
        }
        return gradient
    }

    static func gradient(from template: GradientOption, context: NSManagedObjectContext) -> Gradient {
        return Gradient.findOrCreate(context: context, name: template.name, startColor: template.colorHex[0], endColor: template.colorHex[1])
    }
}

extension NSManagedObjectContext {
    @discardableResult
    func createGradient(name: String, startColor: Int64, endColor: Int64) throws -> Gradient {
        let item = Gradient.create(context: self, name: name, startColor: startColor, endColor: endColor)
        try performSave()
        return item
    }
}
