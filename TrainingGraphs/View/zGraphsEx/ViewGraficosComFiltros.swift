//
//  ViewGraficosComFiltros.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 30/10/25.
//

import SwiftUI
import Charts

enum PeriodoFiltro: String, CaseIterable {
    case semana = "7D"
    case mes = "1M"
    case tresMeses = "3M"
    case ano = "1A"
    case tudo = "Tudo"
    
    var descricao: String {
        switch self {
        case .semana: return "Última Semana"
        case .mes: return "Último Mês"
        case .tresMeses: return "3 Meses"
        case .ano: return "Último Ano"
        case .tudo: return "Todas"
        }
    }
}

struct ViewGraficosComFiltros: View {
    let corridas: [Run]
    @State private var periodoSelecionado: PeriodoFiltro = .mes
    
    var corridasFiltradas: [Run] {
        let agora = Date()
        let calendar = Calendar.current
        
        return corridas.filter { corrida in
            switch periodoSelecionado {
            case .semana:
                return calendar.dateComponents([.day], from: corrida.date, to: agora).day ?? 0 <= 7
            case .mes:
                return calendar.dateComponents([.day], from: corrida.date, to: agora).day ?? 0 <= 30
            case .tresMeses:
                return calendar.dateComponents([.day], from: corrida.date, to: agora).day ?? 0 <= 90
            case .ano:
                return calendar.dateComponents([.day], from: corrida.date, to: agora).day ?? 0 <= 365
            case .tudo:
                return true
            }
        }.sorted { $0.date < $1.date }
    }
    
    var estatisticas: (total: Double, media: Double, melhor: Double) {
        let total = corridasFiltradas.reduce(0) { $0 + $1.distanceKm }
        let media = corridasFiltradas.isEmpty ? 0 : total / Double(corridasFiltradas.count)
        let melhor = corridasFiltradas.map { $0.distanceKm }.max() ?? 0
        return (total, media, melhor)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header com título
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estatísticas de Corrida")
                        .font(.largeTitle.bold())
                    Text("\(corridasFiltradas.count) corridas no período")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Filtros de período
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PeriodoFiltro.allCases, id: \.self) { periodo in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    periodoSelecionado = periodo
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(periodo.rawValue)
                                        .font(.headline)
                                    Text(periodo.descricao)
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    periodoSelecionado == periodo
                                    ? Color.blue
                                    : Color(.systemGray5)
                                )
                                .foregroundStyle(
                                    periodoSelecionado == periodo
                                    ? .white
                                    : .primary
                                )
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Cards de estatísticas
                HStack(spacing: 16) {
                    StatCard(
                        titulo: "Total",
                        valor: "\(estatisticas.total, default: "%.1f")",
                        unidade: "km",
                        cor: .blue
                    )
                    
                    StatCard(
                        titulo: "Média",
                        valor: "\(estatisticas.media, default: "%.1f")",
                        unidade: "km",
                        cor: .green
                    )
                    
                    StatCard(
                        titulo: "Melhor",
                        valor: "\(estatisticas.melhor, default: "%.1f")",
                        unidade: "km",
                        cor: .orange
                    )
                }
                .padding(.horizontal)
                
                // Gráfico principal
                if !corridasFiltradas.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Evolução da Distância")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(corridasFiltradas) { corrida in
                            LineMark(
                                x: .value("Data", corrida.date),
                                y: .value("Distância", corrida.distanceKm)
                            )
                            .foregroundStyle(Color.blue.gradient)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .interpolationMethod(.catmullRom)
                            
                            AreaMark(
                                x: .value("Data", corrida.date),
                                y: .value("Distância", corrida.distanceKm)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            PointMark(
                                x: .value("Data", corrida.date),
                                y: .value("Distância", corrida.distanceKm)
                            )
                            .foregroundStyle(Color.blue)
                            .symbolSize(60)
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: formatoData)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let km = value.as(Double.self) {
                                        Text("\(km, specifier: "%.0f") km")
                                    }
                                }
                            }
                        }
                        .frame(height: 280)
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView(
                        "Sem Dados",
                        systemImage: "chart.line.downtrend.xyaxis",
                        description: Text("Nenhuma corrida no período selecionado")
                    )
                    .frame(height: 300)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    var formatoData: Date.FormatStyle {
        switch periodoSelecionado {
        case .semana:
            return .dateTime.weekday().day()
        case .mes, .tresMeses:
            return .dateTime.day().month()
        case .ano, .tudo:
            return .dateTime.month().year()
        }
    }
}

struct StatCard: View {
    let titulo: String
    let valor: String
    let unidade: String
    let cor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(valor)
                    .font(.title2.bold())
                Text(unidade)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(cor.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ViewGraficosComFiltros(corridas: Run.mockArrayRuns())
//    ViewGraficosComFiltros(corridas: [])
}
