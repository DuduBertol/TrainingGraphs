//
//  GraphView.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 29/10/25.
//

import SwiftUI
import SwiftData
import Charts

struct GraphPlusView: View {
    @State private var runs: [Run] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ViewGraficosComFiltros(corridas: runs)
                    GraficoMultiMetrica(corridas: runs)
                    GraficoInterativo(corridas: runs)
                }
            }
            .navigationTitle("Estatísticas")
        }
        .onAppear {
            loadRuns()
        }
    }
    
    func loadRuns() {
        runs = Run.mockArrayRuns()
    }
}


#Preview {
    GraphPlusView()
}
