import SwiftUI
import SwiftData

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var itemDescription: String = ""
    @State private var status: TodoStatus = .notStarted
    @State private var priority: Priority = .medium
    @State private var dueDate: Date = Date().addingTimeInterval(24 * 60 * 60) // Next day
    @State private var hasDueDate: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Todo Details")) {
                    TextField("Title", text: $title)
                    
                    TextField("Description", text: $itemDescription, axis: .vertical)
                        .lineLimit(4...)
                    
                    Picker("Status", selection: $status) {
                        Text(TodoStatus.notStarted.rawValue).tag(TodoStatus.notStarted)
                        Text(TodoStatus.inProgress.rawValue).tag(TodoStatus.inProgress)
                        Text(TodoStatus.completed.rawValue).tag(TodoStatus.completed)
                    }
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("New Todo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addItem() {
        let newItem = Item(
            title: title,
            itemDescription: itemDescription,
            status: status,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority
        )
        
        if status == .completed {
            newItem.completionDate = Date()
        }
        
        modelContext.insert(newItem)
        dismiss()
    }
}

#Preview {
    AddTodoView()
        .modelContainer(for: Item.self, inMemory: true)
} 