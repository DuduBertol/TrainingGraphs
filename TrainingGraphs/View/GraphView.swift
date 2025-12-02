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
//        @Query(sort: \Run.date) private var runs: [Run]
    let runs = Run.mockArrayRuns()
    
    @State var selectedRunUnit: RunUnits = .distance
    @State var selectedDateRange: DateRange = .week
    
    var filteredRuns: [Run] {
        let calendar = Calendar.current
        // Pega a data de hoje e subtrai X dias baseado na seleção
        guard let cutoffDate = calendar.date(byAdding: .day, value: -selectedDateRange.rawValue, to: Date()) else {
            return runs
        }
        
        // Retorna apenas as corridas que aconteceram DEPOIS da data de corte
        return runs.filter { $0.date >= cutoffDate }
    }
    
    var chartBaseline: Double {
        if selectedRunUnit == .pace {
            let maxVal = filteredRuns.map { $0.pace }.max() ?? 0
            return maxVal + 0.5
        } else {
            return 0
        }
    }
    
    var body: some View {
        VStack(spacing: 32){
            Text("Graphs")
                .font(.title)
                .bold()
                .foregroundStyle(.opacity(0.5))
            
            VStack{
                //MARK: - Period Selector
                
                Picker("Period", selection: Binding(
                    get: { selectedDateRange },
                    set: { newValue in
                        withAnimation(.easeInOut) {
                            selectedDateRange = newValue
                        }
                    }
                )){
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
//                HStack{
//                    ForEach(DateRange.allCases, id: \.self) { range in
//                        Button{
//                            withAnimation() {
//                                selectedDateRange = range
//                            }
//                        } label: {
//                            HStack(spacing: 8){
//                                Text("\(range.title)")
//                                    .font(.subheadline.weight(.medium))
//                            }
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 4)
//                            .background(selectedDateRange == range ? Color.blue.opacity(0.2) : Color(.systemGray6))
//                            .cornerRadius(20)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(
//                                        selectedDateRange == range ? Color.blue : Color.clear,
//                                        lineWidth: 2
//                                    )
//                            )
//                        }
//                        .buttonStyle(.plain)
//                    }
//                }
                
                
                //MARK: - Unit Selector
                HStack(spacing: 12) {
                    ForEach(RunUnits.allCases, id: \.self) { unit in
                        Button{
                            withAnimation() {
                                selectedRunUnit = unit
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
                            .background(selectedRunUnit == unit ? unit.color.opacity(0.2) : Color(.systemGray6))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        selectedRunUnit == unit ? unit.color : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
                .frame(height: 50)
            }
            
            //MARK: - Chart
            Chart(filteredRuns) { run in
                //LINE
                LineMark(
                    x: .value("Date", run.date),
                    y: .value("Value", selectedRunUnit.value(of: run))
                )
                .foregroundStyle(selectedRunUnit.color)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .interpolationMethod(.catmullRom)
                
                //AREA
                AreaMark(
                    x: .value("Date", run.date),
                    yStart: .value("Base", chartBaseline),
                    yEnd: .value("Value", selectedRunUnit.value(of: run))
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(selectedRunUnit.color.opacity(0.25))
                
                //POINT
                PointMark(
                    x: .value("Date", run.date),
                    y: .value("Value", selectedRunUnit.value(of: run))
                )
                .foregroundStyle(selectedRunUnit.color)
                .symbolSize(80)
                
            }
            .chartXAxis{
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            .chartYAxis{
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            
                            if selectedRunUnit == .pace {
                                Text("\(val.toMinutesSeconds())")
                            } else {   
                                Text("\(val, specifier: "%.1f") \(selectedRunUnit.unit)")
                            }
                        }
                    }
                }
            }
            .chartYScale(domain: .automatic(includesZero: false, reversed: selectedRunUnit == .pace))
            .frame(height: 280)
            .padding(.vertical)
            
            
            //MARK: - Stats
            HStack(spacing: 16){
                statsView(
                    title: "Average",
                    value: calculateAverage(),
                    icon: "chart.bar.fill"
                )
                statsView(
                    title: "Best",
                    value: calculateBest(),
                    icon: "arrow.up.circle.fill"
                )
                statsView(
                    title: "Last",
                    value: calculateLast(),
                    icon: "clock.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        //        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        
        
        Spacer()
    }
    
    
    //MARK: - Funcs
    @ViewBuilder
    func statsView(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8){
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(selectedRunUnit.color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(selectedRunUnit.color.opacity(0.1))
        .cornerRadius(12)
    }
    
    func calculateAverage() -> String {
        if filteredRuns.isEmpty { return "- \(selectedRunUnit.unit)"}
        
        let values = filteredRuns.map { selectedRunUnit.value(of: $0) }
        let average = values.reduce(0, +) / Double(values.count)
        
        
        if selectedRunUnit == .pace {
            return "\(average.toMinutesSeconds()) \(selectedRunUnit.unit)"
        } else {
            return String(format: "%.1f %@", average, selectedRunUnit.unit)
        }
    }
    
    func calculateBest() -> String {
        if filteredRuns.isEmpty { return "- \(selectedRunUnit.unit)"}
        
        let values = filteredRuns.map { selectedRunUnit.value(of: $0) }
        let best: Double
        
        if selectedRunUnit == .pace {
            best = values.min() ?? 0
        } else {
            best = values.max() ?? 0
        }
        
        if selectedRunUnit == .pace {
            return "\(best.toMinutesSeconds()) \(selectedRunUnit.unit)"
        } else {
            return String(format: "%.1f %@", best, selectedRunUnit.unit)
        }
    }
    
    func calculateLast() -> String {
        guard let last = filteredRuns.last else { return "-" }
        let value = selectedRunUnit.value(of: last)
        
        if selectedRunUnit == .pace {
            return "\(value.toMinutesSeconds()) \(selectedRunUnit.unit)"
        } else {
            return String(format: "%.1f %@", value, selectedRunUnit.unit)
        }
    }
    
    
}

#Preview {
    GraphView()
}
