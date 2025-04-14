//
//  TaskEntity+CoreDataProperties.swift
//  effectMobileTestTask
//
//  Created by Роман on 08.04.2025.
//
//

import Foundation
import CoreData


extension TaskEntity: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var title: String?
    @NSManaged public var createdAt: Date?

}
