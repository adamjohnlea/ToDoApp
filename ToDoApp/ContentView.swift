//
//  ContentView.swift
//  ToDoApp
//
//  Created by Adam Lea on 3/26/25.
//

import SwiftUI
import SwiftData

// Reference to other files in the project
// (These aren't actual imports but help make dependencies explicit)
// Item.swift - defines the data model
// TodoListView.swift - contains TodoListView
// StatsView.swift - contains StatsView

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodoListView()
            }
            .tabItem {
                Label("Todos", systemImage: "checklist")
            }
            .tag(0)
            
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
