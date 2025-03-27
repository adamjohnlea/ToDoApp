import SwiftUI
import SwiftData

struct TodoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: Item
    @State private var isEditing: Bool = false
    
    var body: some View {
        Form {
            if isEditing {
                Section(header: Text("Todo Details")) {
                    TextField("Title", text: $item.title)
                    
                    TextField("Description", text: $item.itemDescription, axis: .vertical)
                        .lineLimit(4...)
                    
                    Picker("Status", selection: $item.status) {
                        Text(TodoStatus.notStarted.rawValue).tag(TodoStatus.notStarted)
                        Text(TodoStatus.inProgress.rawValue).tag(TodoStatus.inProgress)
                        Text(TodoStatus.completed.rawValue).tag(TodoStatus.completed)
                    }
                    .onChange(of: item.status) { oldValue, newValue in
                        if newValue == .completed && oldValue != .completed {
                            item.completionDate = Date()
                        } else if newValue != .completed {
                            item.completionDate = nil
                        }
                    }
                    
                    Picker("Priority", selection: $item.priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    DatePicker("Due Date", selection: Binding(
                        get: { item.dueDate ?? Date() },
                        set: { item.dueDate = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("No Due Date", isOn: Binding(
                        get: { item.dueDate == nil },
                        set: { if $0 { item.dueDate = nil } else { item.dueDate = Date() } }
                    ))
                }
            } else {
                Section(header: Text("Todo Details")) {
                    LabeledContent("Title", value: item.title)
                    
                    if !item.itemDescription.isEmpty {
                        LabeledContent("Description") {
                            Text(item.itemDescription)
                        }
                    }
                    
                    LabeledContent("Status", value: item.status.rawValue)
                    LabeledContent("Priority", value: item.priority.rawValue)
                    
                    if let dueDate = item.dueDate {
                        LabeledContent("Due Date") {
                            Text(dueDate, format: .dateTime)
                        }
                    }
                    
                    LabeledContent("Created") {
                        Text(item.creationDate, format: .dateTime)
                    }
                    
                    if let completionDate = item.completionDate {
                        LabeledContent("Completed") {
                            Text(completionDate, format: .dateTime)
                        }
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Todo" : "Todo Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
            
            if !isEditing {
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        modelContext.delete(item)
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let example = Item(title: "Example Todo", itemDescription: "This is an example todo item with a longer description that shows how text wraps.", status: .inProgress, priority: .high)
        example.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        
        return NavigationStack {
            TodoDetailView(item: example)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
} 