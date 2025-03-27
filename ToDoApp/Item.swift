//
//  Item.swift
//  ToDoApp
//
//  Created by Adam Lea on 3/26/25.
//

import Foundation
import SwiftData

enum TodoStatus: String, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
}

enum Priority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

@Model
final class Item {
    var title: String
    var itemDescription: String
    var status: TodoStatus
    var dueDate: Date?
    var priority: Priority
    var creationDate: Date
    var completionDate: Date?
    
    init(title: String, itemDescription: String = "", status: TodoStatus = .notStarted, dueDate: Date? = nil, priority: Priority = .medium) {
        self.title = title
        self.itemDescription = itemDescription
        self.status = status
        self.dueDate = dueDate
        self.priority = priority
        self.creationDate = Date()
        self.completionDate = nil
    }
}
