//
//  GraphView.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 29/10/25.
//

import SwiftUI
import SwiftData
import Charts


struct GraphView: View {
    @Environment(\.modelContext) private var context
    
//    @Query(sort: \Run.date) private var allRuns: [Run]
    // Em produção, use @Query. Para teste, use o mock:
    let allRuns = Run.mockArrayRuns()
    
    @StateObject var vm = GraphViewModel()
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        let currentRuns = vm.filteredRuns(allRuns)
        
        ScrollView {
            VStack(spacing: 32) {
                Text("Graphs")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.opacity(0.5))
                
                
                VStack(spacing: 24){
                    //MARK: - Intervals
                    Picker("Time Range", selection: $vm.selectedTimeRange) {
                        ForEach(GraphTimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    //MARK: - Date Navigator
                    DateRangeStepper(vm: vm)
                    
                    //MARK: - Unit Selector
                    unitSelector
                }
                
                //MARK: - Graph
                if currentRuns.isEmpty {
                    ContentUnavailableView("No runs in this period", systemImage: "chart.xyaxis.line")
                        .frame(height: 280)
                } else {
                    chartView(runs: currentRuns)
                }
                
                //MARK: - Stats
                statsSection(runs: currentRuns)
            }
            .padding()
        }
    }
    
    // MARK: - Subviews para organizar
    
    var unitSelector: some View {
        HStack(spacing: 12) {
            ForEach(RunUnits.allCases, id: \.self) { unit in
                Button{
                    withAnimation() {
                        vm.selectedRunUnit = unit
                    }
                } label: {
                    HStack(spacing: 8){
                        Circle()
                            .fill(unit.color)
                            .frame(width: 8, height: 8)
                        
                        Text(unit.rawValue)
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(vm.selectedRunUnit == unit ? unit.color.opacity(0.2) : Color(.systemGray6))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                vm.selectedRunUnit == unit ? unit.color : Color.clear,
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 4)
    }
    
    func chartView(runs: [Run]) -> some View {
        Chart(runs) { run in
            // LINE
            LineMark(
                x: .value("Date", run.date),
                y: .value("Value", vm.selectedRunUnit.value(of: run))
            )
            .foregroundStyle(vm.selectedRunUnit.color)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .interpolationMethod(.catmullRom)
            
            // AREA
            AreaMark(
                x: .value("Date", run.date),
                yStart: .value("Base", vm.getChartBaseline(for: runs)),
                yEnd: .value("Value", vm.selectedRunUnit.value(of: run))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(vm.selectedRunUnit.color.opacity(0.25))
            
            // POINT
            PointMark(
                x: .value("Date", run.date),
                y: .value("Value", vm.selectedRunUnit.value(of: run))
            )
            .foregroundStyle(vm.selectedRunUnit.color)
            .symbolSize(40) // Reduzi um pouco o tamanho
        }
        // --- EIXO X DINÂMICO ---
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        // Formatação condicional
                        switch vm.selectedTimeRange {
                        case .week:
                            // Se for semana, mostra Dia da Semana (Seg, Ter)
                            VStack(spacing: 0) {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                                    .font(.caption2)
                                    .bold()
                                Text(date, format: .dateTime.day())
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        case .month, .threeMonths:
                            // Se for Mês, mostra dia numérico (01, 05, 10)
                            Text(date, format: .dateTime.day())
                                .font(.caption2)
                        case .sixMonths, .year:
                            // Se for ano, mostra o Mês (Jan, Fev)
                            Text(date, format: .dateTime.month(.narrow))
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let val = value.as(Double.self) {
                        Text(vm.getValueForMetric(val))
                            .font(.caption2)
                            .bold()
                    }
                }
            }
        }
        .chartYScale(domain: .automatic(includesZero: false, reversed: vm.selectedRunUnit == .pace))
        .frame(height: 250)
    }
    
    func statsSection(runs: [Run]) -> some View {
        ViewThatFits{
            HStack(spacing: 16) {
                statsView(title: "Avg", value: vm.calculateAverage(for: runs), icon: "chart.bar.fill")
                statsView(title: "Best", value: vm.calculateBest(for: runs), icon: "trophy.fill")
                statsView(title: "Last", value: vm.calculateLast(for: runs), icon: "clock.arrow.circlepath")
            }
            
            VStack(spacing: 16) {
                statsView(title: "Avg", value: vm.calculateAverage(for: runs), icon: "chart.bar.fill")
                statsView(title: "Best", value: vm.calculateBest(for: runs), icon: "trophy.fill")
                statsView(title: "Last", value: vm.calculateLast(for: runs), icon: "clock.arrow.circlepath")
            }
        }
    }
    
    func statsView(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8){
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(vm.selectedRunUnit.color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                Text(vm.selectedRunUnit.unit)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(vm.selectedRunUnit.color.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
    }
}


#Preview {
    GraphView()
}
