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
    
        @Query(sort: \Run.date) private var allRuns: [Run]
    // Em produção, use @Query. Para teste, use o mock:
//    let allRuns = Run.mockArrayRuns()
    
    @StateObject var vm = GraphViewModel()
    
    @State var isOpenNewRunSheet: Bool = false
    @State var isOpenHistorySheet: Bool = false
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        let currentRuns = vm.filteredRuns(allRuns)
        
        NavigationStack{
            ScrollView {
                VStack(spacing: 32) {
                    Text("Run Charts")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.opacity(0.5))
                        .accessibilityAddTraits(.isHeader)
                    
                    
                    VStack(spacing: 24){
                        //MARK: - Intervals
                        Picker("Time Range", selection: $vm.selectedTimeRange) {
                            ForEach(GraphTimeRange.allCases) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Time Interval")
                        
                        //MARK: - Date Navigator
                        DateRangeStepper(vm: vm)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Selected Period")
                            .accessibilityValue(vm.getDateRangeLabel())
                            .accessibilityAdjustableAction { direction in
                                switch direction {
                                case .increment:
                                    vm.moveTimeRange(direction: 1)
                                case .decrement:
                                    vm.moveTimeRange(direction: -1)
                                @unknown default:
                                    break
                                }
                            }
                            .accessibilityHint("Swipe up or down to change the period")
                        
                        //MARK: - Unit Selector
                        unitSelector
                    }
                    
                    //MARK: - Graph
                    if currentRuns.isEmpty {
                        ContentUnavailableView("No runs in this period", systemImage: "chart.xyaxis.line")
                            .frame(height: 280)
                    } else {
                        chartView(runs: currentRuns)
                            .accessibilityLabel("Evolution graph by \(vm.selectedRunUnit.rawValue)")
                            .accessibilityHint("Shows data for \(vm.getDateRangeLabel())")
                    }
                    
                    //MARK: - Stats
                    statsSection(runs: currentRuns)
                }
                .padding()
            }
//            .navigationTitle("Run Charts")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isOpenNewRunSheet = true
                    }label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isOpenHistorySheet = true
                    }label: {
                        Image(systemName: "clock")
                    }
                }
            }
            
            .sheet(isPresented: $isOpenNewRunSheet) {
                NewRunView()
            }
            .sheet(isPresented: $isOpenHistorySheet) {
                HistoryView()
            }
            
        }
        
        
    }
    
    // MARK: - Subviews
    
    var unitSelector: some View {
        ViewThatFits(in: .horizontal) {
            selectorButtons
            
            ScrollView(.horizontal, showsIndicators: false) {
                selectorButtons
            }
        }
    }
    
    var selectorButtons: some View {
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
                .accessibilityLabel(unit.rawValue)
                .accessibilityAddTraits(vm.selectedRunUnit == unit ? [.isButton, .isSelected] : [.isButton])
            }
        }
        .padding(.horizontal, 4)
    }
    
    func chartView(runs: [Run]) -> some View {
        Chart(runs) { run in
            // 1. LINHA (Elemento Principal de Acessibilidade)
            // Define a tendência e a "melodia" do gráfico
            LineMark(
                x: .value("Date", run.date, unit: .day),
                y: .value(vm.selectedRunUnit.rawValue, vm.selectedRunUnit.value(of: run))
            )
            .foregroundStyle(vm.selectedRunUnit.color)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .interpolationMethod(.catmullRom)
            // Acessibilidade: O que o VoiceOver lê quando o dedo passa aqui
            .accessibilityLabel(run.date.formatted(date: .abbreviated, time: .omitted))
            .accessibilityValue("\(vm.getValueForMetric(vm.selectedRunUnit.value(of: run))) \(vm.selectedRunUnit.unit)")
            
            // 2. ÁREA (Visual / Decorativo)
            AreaMark(
                x: .value("Date", run.date, unit: .day),
                yStart: .value("Base", vm.getChartBaseline(for: runs)),
                yEnd: .value(vm.selectedRunUnit.rawValue, vm.selectedRunUnit.value(of: run))
            )
            .foregroundStyle(vm.selectedRunUnit.color.opacity(0.25))
            .interpolationMethod(.catmullRom)
            .accessibilityHidden(true) // Escondemos para não duplicar a leitura
            
            // 3. PONTOS (Marcadores Visuais)
            PointMark(
                x: .value("Date", run.date, unit: .day),
                y: .value(vm.selectedRunUnit.rawValue, vm.selectedRunUnit.value(of: run))
            )
            .foregroundStyle(vm.selectedRunUnit.color)
            .symbolSize(40)
            .accessibilityHidden(true) // O VoiceOver já lê esses valores através da Linha
        }
        // --- EIXO X (Datas) ---
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        switch vm.selectedTimeRange {
                        case .week:
                            VStack(spacing: 0) {
                                Text(date, format: .dateTime.weekday(.abbreviated)).bold()
                                Text(date, format: .dateTime.day()).foregroundStyle(.secondary)
                            }
                        case .month, .threeMonths:
                            Text(date, format: .dateTime.day())
                        case .sixMonths, .year:
                            Text(date, format: .dateTime.month(.narrow))
                        }
                    }
                }
            }
        }
        // --- EIXO Y (Valores) ---
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
        // Configuração de Escala (inverte se for Pace, pois menor é melhor)
        .chartYScale(domain: .automatic(includesZero: false, reversed: vm.selectedRunUnit == .pace))
        .frame(minHeight: 250)
        
        // --- Resumo Global para o VoiceOver ---
        // Isso é o que é lido antes do usuário entrar no gráfico
        .accessibilityLabel("Evolution Graph of \(vm.selectedRunUnit.rawValue)")
        .accessibilityHint("Show data from \(vm.getDateRangeLabel()). Use the rotor to listen the Audio Graph")
    }
    
    func statsSection(runs: [Run]) -> some View {
        ViewThatFits {
            HStack(spacing: 16) {
                statsContent(runs: runs)
            }
            
            VStack(spacing: 16) {
                statsContent(runs: runs)
            }
        }
    }
    
    @ViewBuilder
    func statsContent(runs: [Run]) -> some View {
        statsView(title: "Avg", value: vm.calculateAverage(for: runs), icon: "chart.bar.fill", semanticLabel: "Average")
        statsView(title: "Best", value: vm.calculateBest(for: runs), icon: "trophy.fill", semanticLabel: "Best")
        statsView(title: "Last", value: vm.calculateLast(for: runs), icon: "clock.arrow.circlepath", semanticLabel: "Last")
        
    }
    
    func statsView(title: String, value: String, icon: String, semanticLabel: String) -> some View {
        VStack(spacing: 8){
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(vm.selectedRunUnit.color)
                .accessibilityHidden(true)
            
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
        .accessibilityLabel("\(semanticLabel)")
        .accessibilityValue("\(value) \(vm.selectedRunUnit.unit)")
    }
}


#Preview {
    GraphView()
}

