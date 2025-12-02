//
//  GraphView.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 29/10/25.
//

import SwiftUI
import SwiftData
import Charts

struct SimpleGraphView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Run.date) private var runs: [Run]
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 8){
                Text("Km Volume")
                    .font(.title2)
                    .bold()
                Chart {
                    ForEach(Run.mockArrayRuns()){ run in
                        BarMark(
                            x: .value("Run", run.dateFormatted),
                            y: .value("Kms", run.distanceKm)
                        )
                        
                    }
                }
                
                Chart {
                    ForEach(Run.mockArrayRuns()){ run in
                        LineMark(
                            x: .value("Run", run.dateFormatted),
                            y: .value("Kms", run.distanceKm)
                        )
                        
                    }
                }
            }
            .padding(.bottom, 32)
            
            VStack(alignment: .leading, spacing: 8){
                Text("Time Volume")
                    .font(.title2)
                    .bold()
                Chart {
                    ForEach(Run.mockArrayRuns()){ run in
                        BarMark(
                            x: .value("Run", run.dateFormatted),
                            y: .value("Time", run.durationMin)
                        )
                        
                    }
                }
                
                Chart {
                    ForEach(Run.mockArrayRuns()){ run in
                        LineMark(
                            x: .value("Run", run.dateFormatted),
                            y: .value("Time", run.durationMin)
                        )
                        
                    }
                }
            }
        }
        .padding()
    }

}

#Preview {
    SimpleGraphView()
}
