//
//  ToDoAppApp.swift
//  ToDoApp
//
//  Created by Adam Lea on 3/26/25.
//

import SwiftUI
import SwiftData

@main
struct ToDoAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await seedDatabase()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func seedDatabase() async {
        let context = ModelContext(sharedModelContainer)
        
        // Check if we have any existing items
        let descriptor = FetchDescriptor<Item>()
        do {
            let existingItems = try context.fetch(descriptor)
            guard existingItems.isEmpty else { return }
            
            // Add sample data
            let calendar = Calendar.current
            let now = Date()
            
            // Sample 1: High priority, due today
            let highPriorityTodo = Item(
                title: "Finish project proposal",
                itemDescription: "Complete the draft and send to the team for review",
                status: .inProgress,
                dueDate: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now),
                priority: .high
            )
            
            // Sample 2: Medium priority, due tomorrow
            let mediumPriorityTodo = Item(
                title: "Weekly team meeting",
                itemDescription: "Prepare agenda and discussion points",
                status: .notStarted,
                dueDate: calendar.date(byAdding: .day, value: 1, to: now),
                priority: .medium
            )
            
            // Sample 3: Low priority, due next week
            let lowPriorityTodo = Item(
                title: "Research new technologies",
                itemDescription: "Look into SwiftData and latest SwiftUI features",
                status: .notStarted,
                dueDate: calendar.date(byAdding: .day, value: 7, to: now),
                priority: .low
            )
            
            // Sample 4: Completed task
            let completedTodo = Item(
                title: "Set up project repository",
                itemDescription: "Create Git repo and invite team members",
                status: .completed,
                dueDate: calendar.date(byAdding: .day, value: -2, to: now),
                priority: .high
            )
            completedTodo.completionDate = calendar.date(byAdding: .hour, value: -12, to: now)
            
            // Sample 5: No due date
            let noDueDateTodo = Item(
                title: "Brainstorm app ideas",
                itemDescription: "Think about potential new features",
                status: .notStarted,
                dueDate: nil,
                priority: .medium
            )
            
            context.insert(highPriorityTodo)
            context.insert(mediumPriorityTodo)
            context.insert(lowPriorityTodo)
            context.insert(completedTodo)
            context.insert(noDueDateTodo)
            
            try context.save()
        } catch {
            print("Error seeding database: \(error)")
        }
    }
}
