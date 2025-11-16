# ToDoApp

A modern, feature-rich todo list application built with SwiftUI and SwiftData for iOS. Track your tasks with priorities, due dates, and visualize your productivity with interactive statistics.

## Features

### Core Functionality
- **Create, Read, Update, Delete** todos with full CRUD operations
- **Task Status Tracking**: Not Started, In Progress, Completed
- **Priority Levels**: Low, Medium, High with visual indicators
- **Due Date Management**: Optional due dates with date/time selection
- **Automatic Timestamps**: Tracks creation and completion dates

### Organization & Filtering
- **Search**: Full-text search across titles and descriptions
- **Filter by Status**: View specific task states (Not Started, In Progress, Completed)
- **Filter by Priority**: Focus on High, Medium, or Low priority items
- **Multiple Sort Options**:
  - Due Date (with items without dates last)
  - Priority (High → Medium → Low)
  - Title (alphabetical)
  - Status (In Progress → Not Started → Completed)

### User Experience
- **Swipe Actions**:
  - Swipe left to delete
  - Swipe right to mark complete or start task
- **Visual Indicators**:
  - Past due items highlighted with warning icon
  - High priority items flagged
  - Status icons for quick recognition
  - Color-coded priority badges
- **Empty State**: Helpful prompts with quick actions to create todos or load sample data

### Statistics Dashboard
Interactive charts powered by Swift Charts framework:
- **Status Distribution**: Donut chart showing breakdown of Not Started, In Progress, and Completed tasks
- **Priority Distribution**: Bar chart displaying task counts by priority level
- **Completion Trend**: 7-day line graph showing daily completion history

## Technical Stack

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Apple's latest persistence framework for data modeling and storage
- **Swift Charts**: Native charting framework for data visualization
- **iOS Deployment Target**: iOS 17.0+

## Project Structure

```
ToDoApp/
├── ToDoApp/
│   ├── ToDoAppApp.swift          # App entry point with SwiftData container setup
│   ├── ContentView.swift         # Tab view coordinator (Todos & Stats tabs)
│   ├── Item.swift                # Data model with TodoStatus and Priority enums
│   ├── TodoListView.swift        # Main list view with search/filter/sort
│   ├── TodoDetailView.swift      # Detail/edit view for individual todos
│   ├── AddTodoView.swift         # Form for creating new todos
│   └── StatsView.swift           # Statistics dashboard with charts
└── SampleDataUtility.swift       # Utility for generating test data
```

## Data Model

### Item (SwiftData Model)
- `title: String` - Task title
- `itemDescription: String` - Optional detailed description
- `status: TodoStatus` - Current status (.notStarted, .inProgress, .completed)
- `dueDate: Date?` - Optional due date with time
- `priority: Priority` - Task priority (.low, .medium, .high)
- `creationDate: Date` - Auto-set on creation
- `completionDate: Date?` - Auto-set when marked complete

### Enums
- **TodoStatus**: notStarted, inProgress, completed
- **Priority**: low, medium, high (CaseIterable & Codable)

## Key Functionalities

### Automatic Completion Tracking
When a task's status changes to "Completed", the `completionDate` is automatically set. If changed back to another status, the completion date is cleared.

### Smart Sorting
- **Due Date**: Items with due dates appear first, sorted by date, followed by items without due dates
- **Priority**: High → Medium → Low, with alphabetical sub-sorting
- **Status**: In Progress → Not Started → Completed, with alphabetical sub-sorting
- Safe sorting implementation without force unwrapping

### Database Seeding
On first launch, the app automatically seeds the database with sample todos for demonstration:
- High priority task due today
- Medium priority task due tomorrow
- Low priority task due next week
- Completed task from the past
- Task without a due date

Sample data can also be manually added via the "Load Sample Data" button when the list is empty.

## Installation & Running

1. Clone the repository
2. Open `ToDoApp.xcodeproj` in Xcode 15.0 or later
3. Select your target device or simulator (iOS 17.0+)
4. Build and run (⌘R)

## Usage Tips

- **Quick Complete**: Swipe right on any task to quickly mark it complete
- **Start Task**: Swipe right on a "Not Started" task to begin working on it
- **Filter Active**: Look for the pulsing filter icon when filters are applied
- **Clear Filters**: Use the "Clear Filters" option in the filter menu to reset all filters
- **Track Progress**: Check the Stats tab to visualize your productivity trends

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Future Enhancement Ideas

- Categories/Tags for better organization
- Recurring tasks
- Notifications for due dates
- Collaboration/sharing
- Dark mode optimizations
- Widgets for home screen
- iCloud sync across devices

## License

This project is available for personal and educational use.

## Author

Created by Adam Lea
