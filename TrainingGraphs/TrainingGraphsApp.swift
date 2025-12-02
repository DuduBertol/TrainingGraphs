//
//  TrainingGraphsApp.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 28/10/25.
//

import SwiftUI
import SwiftData

@main
struct TrainingGraphsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Run.self])
    }
}
