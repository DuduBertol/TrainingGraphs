//
//  GraficoInterativo.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 30/10/25.
//
import SwiftUI
import Charts

struct GraficoInterativo: View {
    let corridas: [Run]
    @State private var dataSelecionada: Date?
    
    var corridaSelecionada: Run? {
        guard let data = dataSelecionada else { return nil }
        return corridas.min(by: { abs($0.date.timeIntervalSince(data)) < abs($1.date.timeIntervalSince(data)) })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Evolução - Toque para Detalhes")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Chart {
                ForEach(corridas) { corrida in
                    LineMark(
                        x: .value("Data", corrida.date),
                        y: .value("Distância", corrida.distanceKm)
                    )
                    .foregroundStyle(Color.orange.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Data", corrida.date),
                        y: .value("Distância", corrida.distanceKm)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    PointMark(
                        x: .value("Data", corrida.date),
                        y: .value("Distância", corrida.distanceKm)
                    )
                    .foregroundStyle(Color.orange)
                    .symbolSize(80)
                }
                
                // Destaca o ponto selecionado
                if let selecionada = corridaSelecionada {
                    RuleMark(x: .value("Data", selecionada.date))
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selecionada.date, style: .date)
                                    .font(.caption.bold())
                                Text("\(selecionada.distanceKm, specifier: "%.2f") km")
                                    .font(.caption)
                                Text("\(selecionada.durationMin)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 4)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXSelection(value: $dataSelecionada)
            .frame(height: 300)
            .padding(.vertical)
            
            // Card de informações
            if let selecionada = corridaSelecionada {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Distância")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(selecionada.distanceKm, specifier: "%.2f") km")
                            .font(.title3.bold())
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tempo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(selecionada.durationMin)")
                            .font(.title3.bold())
                    }
                    
//                    Divider()
//                        .frame(height: 40)
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Ritmo")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                        Text("\(selecionada.ritmo, specifier: "%.2f") min/km")
//                            .font(.title3.bold())
//                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .animation(.spring(), value: dataSelecionada)
    }
    
    func formatarTempo(_ segundos: TimeInterval) -> String {
        let horas = Int(segundos) / 3600
        let minutos = (Int(segundos) % 3600) / 60
        let segs = Int(segundos) % 60
        
        if horas > 0 {
            return String(format: "%dh %02dm %02ds", horas, minutos, segs)
        } else {
            return String(format: "%dm %02ds", minutos, segs)
        }
    }
}
