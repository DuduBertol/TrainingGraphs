//
//  GraficoMultiMetrica.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 30/10/25.
//

import SwiftUI
import Charts

enum MetricaCorrida: String, CaseIterable {
    case distancia = "Distância"
    case tempo = "Tempo"
    case ritmo = "Ritmo"
    case velocidade = "Velocidade"
    
    var unidade: String {
        switch self {
        case .distancia: return "km"
        case .tempo: return "min"
        case .ritmo: return "min/km"
        case .velocidade: return "km/h"
        }
    }
    
    var cor: Color {
        switch self {
        case .distancia: return .blue
        case .tempo: return .green
        case .ritmo: return .orange
        case .velocidade: return .purple
        }
    }
    
    func valor(de corrida: Run) -> Double {
        switch self {
        case .distancia:
            return corrida.distanceKm
        case .tempo:
            return Double(corrida.durationMin)
        case .ritmo:
            return 0
        case .velocidade:
            return 0
        }
    }
}

struct GraficoMultiMetrica: View {
    let corridas: [Run]
    @State private var metricaSelecionada: MetricaCorrida = .distancia
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Análise de Performance")
                    .font(.headline)
                Text("Selecione a métrica para visualizar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Seletor de métrica
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MetricaCorrida.allCases, id: \.self) { metrica in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                metricaSelecionada = metrica
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(metrica.cor)
                                    .frame(width: 8, height: 8)
                                
                                Text(metrica.rawValue)
                                    .font(.subheadline.weight(.medium))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                metricaSelecionada == metrica
                                ? metrica.cor.opacity(0.2)
                                : Color(.systemGray6)
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        metricaSelecionada == metrica
                                        ? metrica.cor
                                        : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Gráfico
            Chart(corridas) { corrida in
                LineMark(
                    x: .value("Data", corrida.date),
                    y: .value("Valor", metricaSelecionada.valor(de: corrida))
                )
                .foregroundStyle(metricaSelecionada.cor.gradient)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Data", corrida.date),
                    y: .value("Valor", metricaSelecionada.valor(de: corrida))
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            metricaSelecionada.cor.opacity(0.3),
                            metricaSelecionada.cor.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                PointMark(
                    x: .value("Data", corrida.date),
                    y: .value("Valor", metricaSelecionada.valor(de: corrida))
                )
                .foregroundStyle(metricaSelecionada.cor)
                .symbolSize(80)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text("\(val, specifier: "%.1f") \(metricaSelecionada.unidade)")
                        }
                    }
                }
            }
            .frame(height: 280)
            .padding(.vertical)
            
            // Estatísticas da métrica selecionada
            HStack(spacing: 16) {
                estatisticaView(
                    titulo: "Média",
                    valor: calcularMedia(),
                    icone: "chart.bar.fill"
                )
                
                estatisticaView(
                    titulo: "Melhor",
                    valor: calcularMelhor(),
                    icone: "arrow.up.circle.fill"
                )
                
                estatisticaView(
                    titulo: "Última",
                    valor: calcularUltima(),
                    icone: "clock.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    @ViewBuilder
    func estatisticaView(titulo: String, valor: String, icone: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icone)
                .font(.title3)
                .foregroundStyle(metricaSelecionada.cor)
            
            VStack(spacing: 2) {
                Text(titulo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(valor)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(metricaSelecionada.cor.opacity(0.1))
        .cornerRadius(12)
    }
    
    func calcularMedia() -> String {
        let valores = corridas.map { metricaSelecionada.valor(de: $0) }
        let media = valores.reduce(0, +) / Double(valores.count)
        return String(format: "%.1f %@", media, metricaSelecionada.unidade)
    }
    
    func calcularMelhor() -> String {
        let valores = corridas.map { metricaSelecionada.valor(de: $0) }
        let melhor: Double
        
        // Para ritmo, o menor é melhor; para outros, o maior é melhor
        if metricaSelecionada == .ritmo {
            melhor = valores.min() ?? 0
        } else {
            melhor = valores.max() ?? 0
        }
        
        return String(format: "%.1f %@", melhor, metricaSelecionada.unidade)
    }
    
    func calcularUltima() -> String {
        guard let ultima = corridas.last else { return "N/A" }
        let valor = metricaSelecionada.valor(de: ultima)
        return String(format: "%.1f %@", valor, metricaSelecionada.unidade)
    }
}
