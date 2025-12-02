//
//  ContentView.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 28/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack{
            TabView{
                Tab("", systemImage: "plus"){
                    NewRunView()
                }
                Tab("", systemImage: "chart.xyaxis.line"){
                    GraphView()
                }
                Tab("", systemImage: "clock"){
                    HistoryView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
