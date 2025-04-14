//
//  TaskModel.swift
//  effectMobileTestTask
//
//  Created by Роман on 08.04.2025.
//

import Foundation
import CoreData

struct TaskModel {
    var id : UUID
    var title : String
    var desc : String
    var isCompleted : Bool
    var createdAt : Date
}

extension TaskModel {
    init(from entity: TaskEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.desc = entity.desc ?? ""
        self.createdAt = entity.createdAt ?? Date()
        self.isCompleted = entity.isCompleted
    }
}
