//
//  File.swift
//  
//
//  Created by Tharak on 29/11/20.
//

import Foundation
import CoreData
import CoreDataModelDescription

public struct CoreDataModel {

    public init() { }

    public static let model: NSManagedObjectModel = CoreDataModelDescription(
        entities: [Roll.entity]
    ).makeModel()
}


