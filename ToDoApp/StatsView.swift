import SwiftUI
import SwiftData
import Charts

struct TodoStats {
    let totalCount: Int
    let notStartedCount: Int
    let inProgressCount: Int
    let completedCount: Int
    let completionRate: Double
    let priorityDistribution: [Priority: Int]
    let completionTrend: [Date: Int]
    
    // Computed property to get the percentage distribution
    var statusPercentages: [(status: String, percentage: Double)] {
        let total = Double(totalCount)
        guard total > 0 else { return [] }
        
        return [
            ("Not Started", Double(notStartedCount) / total * 100),
            ("In Progress", Double(inProgressCount) / total * 100),
            ("Completed", Double(completedCount) / total * 100)
        ]
    }
}

struct StatsView: View {
    @Query private var items: [Item]
    
    private var totalCount: Int { items.count }
    private var notStartedCount: Int { items.filter { $0.status == .notStarted }.count }
    private var inProgressCount: Int { items.filter { $0.status == .inProgress }.count }
    private var completedCount: Int { items.filter { $0.status == .completed }.count }
    private var completionRate: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) * 100 : 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview cards
                    HStack(spacing: 16) {
                        statsCard(count: totalCount, title: "Total", systemImage: "checklist", color: .blue)
                        statsCard(count: completedCount, title: "Completed", systemImage: "checkmark.circle.fill", color: .green)
                    }
                    
                    HStack(spacing: 16) {
                        statsCard(count: inProgressCount, title: "In Progress", systemImage: "clock", color: .orange)
                        statsCard(count: notStartedCount, title: "Not Started", systemImage: "circle", color: .red)
                    }
                    
                    // Completion rate
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completion Rate")
                            .font(.headline)
                        
                        HStack {
                            Text("\(Int(completionRate))%")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .frame(height: 20)
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Capsule()
                                    .frame(width: max(CGFloat(completionRate) / 100 * 300, 0), height: 20)
                                    .foregroundColor(.green)
                            }
                            .frame(width: 300)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Distribution circles
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status Distribution")
                            .font(.headline)
                            .padding(.leading)
                        
                        HStack(spacing: 24) {
                            statusCircle(count: completedCount, total: totalCount, color: .green, title: "Completed")
                            statusCircle(count: inProgressCount, total: totalCount, color: .orange, title: "In Progress")
                            statusCircle(count: notStartedCount, total: totalCount, color: .red, title: "Not Started")
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Todo Stats")
            .overlay {
                if totalCount == 0 {
                    ContentUnavailableView {
                        Label("No Todos", systemImage: "chart.bar.xaxis")
                    } description: {
                        Text("Add some todos to see statistics")
                    }
                }
            }
        }
    }
    
    private func statusCircle(count: Int, total: Int, color: Color, title: String) -> some View {
        let percentage = total > 0 ? Double(count) / Double(total) : 0
        
        return VStack {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(percentage))
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(percentage * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
    
    private func statsCard(count: Int, title: String, systemImage: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(count)")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: Item.self, inMemory: true)
} 