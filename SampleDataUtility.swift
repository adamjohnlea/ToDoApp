//
//  SampleDataUtility.swift
//  ToDoApp
//
//  Created by Adam Lea on 3/26/25.
//

import Foundation
import SwiftData

/// Utility for generating sample todo data for testing and demonstration
struct SampleDataUtility {
    
    /// Generates a set of sample todo items
    /// - Returns: An array of pre-configured Item objects
    static func generateSampleItems() -> [Item] {
        let calendar = Calendar.current
        let now = Date()
        
        var items: [Item] = []
        
        // Sample 1: High priority, due today
        let highPriorityTodo = Item(
            title: "Finish project proposal",
            itemDescription: "Complete the draft and send to the team for review",
            status: .inProgress,
            dueDate: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now),
            priority: .high
        )
        items.append(highPriorityTodo)
        
        // Sample 2: Medium priority, due tomorrow
        let mediumPriorityTodo = Item(
            title: "Weekly team meeting",
            itemDescription: "Prepare agenda and discussion points",
            status: .notStarted,
            dueDate: calendar.date(byAdding: .day, value: 1, to: now),
            priority: .medium
        )
        items.append(mediumPriorityTodo)
        
        // Sample 3: Low priority, due next week
        let lowPriorityTodo = Item(
            title: "Research new technologies",
            itemDescription: "Look into SwiftData and latest SwiftUI features",
            status: .notStarted,
            dueDate: calendar.date(byAdding: .day, value: 7, to: now),
            priority: .low
        )
        items.append(lowPriorityTodo)
        
        // Sample 4: Completed task
        let completedTodo = Item(
            title: "Set up project repository",
            itemDescription: "Create Git repo and invite team members",
            status: .completed,
            dueDate: calendar.date(byAdding: .day, value: -2, to: now),
            priority: .high
        )
        completedTodo.completionDate = calendar.date(byAdding: .hour, value: -12, to: now)
        items.append(completedTodo)
        
        // Sample 5: No due date
        let noDueDateTodo = Item(
            title: "Brainstorm app ideas",
            itemDescription: "Think about potential new features",
            status: .notStarted,
            dueDate: nil,
            priority: .medium
        )
        items.append(noDueDateTodo)
        
        return items
    }
    
    /// Seeds a ModelContext with sample data
    /// - Parameter context: The ModelContext to insert sample data into
    /// - Returns: True if seeding was successful, false if data already exists
    @discardableResult
    static func seedDatabase(context: ModelContext) async -> Bool {
        // Check if we have any existing items
        let descriptor = FetchDescriptor<Item>()
        do {
            let existingItems = try context.fetch(descriptor)
            guard existingItems.isEmpty else { 
                return false // Data already exists
            }
            
            // Add sample data
            let sampleItems = generateSampleItems()
            for item in sampleItems {
                context.insert(item)
            }
            
            try context.save()
            return true
        } catch {
            print("Error seeding database: \(error)")
            return false
        }
    }
    
    /// Adds sample data to a ModelContext without checking for existing data
    /// - Parameter context: The ModelContext to insert sample data into
    static func addSampleData(to context: ModelContext) {
        let sampleItems = generateSampleItems()
        for item in sampleItems {
            context.insert(item)
        }
        
        do {
            try context.save()
        } catch {
            print("Error adding sample data: \(error)")
        }
    }
}
