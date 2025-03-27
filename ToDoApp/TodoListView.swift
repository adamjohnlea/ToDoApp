import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddTodo = false
    @State private var statusFilter: TodoStatus?
    @State private var priorityFilter: Priority?
    @State private var sortOption: SortOption = .dueDate
    @State private var showFilters = false
    
    @Query private var allItems: [Item]
    
    enum SortOption: String, CaseIterable {
        case dueDate = "Due Date"
        case priority = "Priority"
        case title = "Title"
        case status = "Status"
    }
    
    // Add sample data function
    private func addSampleData() {
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
        
        modelContext.insert(highPriorityTodo)
        modelContext.insert(mediumPriorityTodo)
        modelContext.insert(lowPriorityTodo)
        modelContext.insert(completedTodo)
        modelContext.insert(noDueDateTodo)
        
        try? modelContext.save()
    }
    
    private var items: [Item] {
        var filtered = allItems
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.itemDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply status filter
        if let statusFilter = statusFilter {
            filtered = filtered.filter { $0.status == statusFilter }
        }
        
        // Apply priority filter
        if let priorityFilter = priorityFilter {
            filtered = filtered.filter { $0.priority == priorityFilter }
        }
        
        // Apply sorting
        return filtered.sorted { item1, item2 in
            switch sortOption {
            case .dueDate:
                if let date1 = item1.dueDate {
                    if let date2 = item2.dueDate {
                        return date1 < date2
                    }
                    return true
                } else if item2.dueDate != nil {
                    return false
                }
                return item1.creationDate < item2.creationDate
                
            case .priority:
                if item1.priority == item2.priority {
                    return item1.title < item2.title
                }
                let order: [Priority] = [.high, .medium, .low]
                return order.firstIndex(of: item1.priority)! < order.firstIndex(of: item2.priority)!
                
            case .title:
                return item1.title < item2.title
                
            case .status:
                if item1.status == item2.status {
                    return item1.title < item2.title
                }
                let order: [TodoStatus] = [.inProgress, .notStarted, .completed]
                return order.firstIndex(of: item1.status)! < order.firstIndex(of: item2.status)!
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(destination: TodoDetailView(item: item)) {
                    TodoRowView(item: item)
                }
                .swipeActions(edge: .leading) {
                    if item.status != .completed {
                        Button {
                            withAnimation {
                                item.status = .completed
                                item.completionDate = Date()
                            }
                        } label: {
                            Label("Complete", systemImage: "checkmark.circle.fill")
                        }
                        .tint(.green)
                    }
                    
                    if item.status == .notStarted {
                        Button {
                            withAnimation {
                                item.status = .inProgress
                            }
                        } label: {
                            Label("Start", systemImage: "play.circle.fill")
                        }
                        .tint(.blue)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation {
                            modelContext.delete(item)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search todos")
        .overlay {
            if allItems.isEmpty {
                ContentUnavailableView {
                    Label("No Todos", systemImage: "checklist")
                } description: {
                    Text("Add a new todo to get started")
                } actions: {
                    VStack {
                        Button("Create Todo") {
                            showingAddTodo = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Load Sample Data") {
                            addSampleData()
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 8)
                    }
                }
            } else if items.isEmpty {
                ContentUnavailableView.search
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddTodo = true
                } label: {
                    Label("Add Todo", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Section("Sort By") {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("Filter Status") {
                        Button("All") {
                            statusFilter = nil
                        }
                        
                        Button("Not Started") {
                            statusFilter = .notStarted
                        }
                        
                        Button("In Progress") {
                            statusFilter = .inProgress
                        }
                        
                        Button("Completed") {
                            statusFilter = .completed
                        }
                    }
                    
                    Section("Filter Priority") {
                        Button("All") {
                            priorityFilter = nil
                        }
                        
                        Button("Low") {
                            priorityFilter = .low
                        }
                        
                        Button("Medium") {
                            priorityFilter = .medium
                        }
                        
                        Button("High") {
                            priorityFilter = .high
                        }
                    }
                    
                    Button("Clear Filters") {
                        statusFilter = nil
                        priorityFilter = nil
                        searchText = ""
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .symbolEffect(.pulse, isActive: statusFilter != nil || priorityFilter != nil)
                }
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTodoView()
        }
        .navigationTitle("Todo List")
    }
}

struct TodoRowView: View {
    let item: Item
    
    private var isPastDue: Bool {
        guard let dueDate = item.dueDate else { return false }
        return dueDate < Date() && item.status != .completed
    }
    
    private var statusColor: Color {
        switch item.status {
        case .notStarted: return .red
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
    
    private var priorityColor: Color {
        switch item.priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: statusImage)
                    .foregroundColor(statusColor)
                
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.status == .completed)
                    .foregroundColor(item.status == .completed ? .secondary : .primary)
                
                Spacer()
                
                if isPastDue {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .symbolEffect(.pulse)
                }
                
                if item.priority == .high {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.red)
                }
            }
            
            if let dueDate = item.dueDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text(dueDate, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundColor(isPastDue ? .red : .secondary)
                }
            }
            
            HStack {
                Circle()
                    .fill(priorityColor)
                    .frame(width: 10, height: 10)
                Text(item.priority.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(item.status.rawValue)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }
        }
    }
    
    private var statusImage: String {
        switch item.status {
        case .notStarted: return "square"
        case .inProgress: return "clock"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

#Preview {
    NavigationStack {
        TodoListView()
    }
    .modelContainer(for: Item.self, inMemory: true)
} 