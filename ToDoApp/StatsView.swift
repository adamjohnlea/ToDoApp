import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var items: [Item]
    
    private var totalCount: Int { items.count }
    private var notStartedCount: Int { items.filter { $0.status == .notStarted }.count }
    private var inProgressCount: Int { items.filter { $0.status == .inProgress }.count }
    private var completedCount: Int { items.filter { $0.status == .completed }.count }
    private var completionRate: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) * 100 : 0
    }
    
    // Priority distribution
    private var priorityData: [(priority: String, count: Int, color: Color)] {
        let lowCount = items.filter { $0.priority == .low }.count
        let mediumCount = items.filter { $0.priority == .medium }.count
        let highCount = items.filter { $0.priority == .high }.count
        
        return [
            ("High", highCount, .red),
            ("Medium", mediumCount, .yellow),
            ("Low", lowCount, .green)
        ]
    }
    
    // Status distribution for charts
    private var statusData: [(status: String, count: Int, color: Color)] {
        return [
            ("Completed", completedCount, .green),
            ("In Progress", inProgressCount, .orange),
            ("Not Started", notStartedCount, .red)
        ]
    }
    
    // Completion trend over time (last 7 days)
    private var completionTrendData: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        
        // Create array for last 7 days
        let dates = (0..<7).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: now)
        }.reversed()
        
        return dates.map { date in
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            
            let completedOnDay = items.filter { item in
                guard let completionDate = item.completionDate else { return false }
                return completionDate >= startOfDay && completionDate < endOfDay
            }.count
            
            return (date: startOfDay, count: completedOnDay)
        }
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
                    
                    // Status Distribution Chart
                    if totalCount > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status Distribution")
                                .font(.headline)
                                .padding(.leading)
                            
                            Chart(statusData, id: \.status) { item in
                                SectorMark(
                                    angle: .value("Count", item.count),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 2
                                )
                                .foregroundStyle(item.color)
                                .cornerRadius(5)
                                .annotation(position: .overlay) {
                                    if item.count > 0 {
                                        Text("\(item.count)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .frame(height: 250)
                            .padding()
                            .chartLegend(position: .bottom, spacing: 10)
                            .chartBackground { chartProxy in
                                GeometryReader { geometry in
                                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                    VStack(spacing: 2) {
                                        Text("\(totalCount)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text("Total")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .position(center)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Priority Distribution Chart
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority Distribution")
                                .font(.headline)
                                .padding(.leading)
                            
                            Chart(priorityData, id: \.priority) { item in
                                BarMark(
                                    x: .value("Priority", item.priority),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(item.color.gradient)
                                .cornerRadius(5)
                                .annotation(position: .top) {
                                    if item.count > 0 {
                                        Text("\(item.count)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Completion Trend Chart
                        if completionTrendData.contains(where: { $0.count > 0 }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Completion Trend (Last 7 Days)")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                Chart(completionTrendData, id: \.date) { item in
                                    LineMark(
                                        x: .value("Date", item.date, unit: .day),
                                        y: .value("Completed", item.count)
                                    )
                                    .foregroundStyle(.green.gradient)
                                    .interpolationMethod(.catmullRom)
                                    
                                    AreaMark(
                                        x: .value("Date", item.date, unit: .day),
                                        y: .value("Completed", item.count)
                                    )
                                    .foregroundStyle(.green.opacity(0.3).gradient)
                                    .interpolationMethod(.catmullRom)
                                    
                                    PointMark(
                                        x: .value("Date", item.date, unit: .day),
                                        y: .value("Completed", item.count)
                                    )
                                    .foregroundStyle(.green)
                                }
                                .frame(height: 200)
                                .padding()
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: 1)) { value in
                                        if let date = value.as(Date.self) {
                                            AxisValueLabel {
                                                Text(date, format: .dateTime.weekday(.narrow))
                                            }
                                            AxisGridLine()
                                        }
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
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