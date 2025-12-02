//
//  Graph3D.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 31/10/25.
//

import SwiftUI
import Charts

struct Graph3D: View {
    
    let runs = Run.mockArrayRuns()
    
    var body: some View {
        Chart3D(runs) { run in
            PointMark(
                x: .value("Date", run.date),
                y: .value("Time", run.durationMin),
                z: .value("Km", run.distanceKm)
            )
        }
    }
}

#Preview {
    Graph3D()
}
