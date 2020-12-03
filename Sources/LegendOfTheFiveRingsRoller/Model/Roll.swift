//
//  File.swift
//
//
//  Created by Tharak on 29/11/20.
//

import Foundation
import CoreData
import CoreDataModelDescription

public class Roll: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var rolls: String
    @NSManaged public var text: String
    @NSManaged public var value: Int16
    @NSManaged public var order: Int16

    public class func fetchRequest() -> NSFetchRequest<Roll> {
        return NSFetchRequest<Roll>(entityName: String(describing: Roll.self))
    }

    static let entity = CoreDataEntityDescription.entity(
        name: String(describing: Roll.self),
        managedObjectClass: Roll.self,
        attributes: [
            .attribute(name: "id", type: .UUIDAttributeType),
            .attribute(name: "rolls", type: .stringAttributeType),
            .attribute(name: "text", type: .stringAttributeType),
            .attribute(name: "value", type: .integer16AttributeType),
            .attribute(name: "order", type: .integer16AttributeType),
        ]
    )
}
