//
//  GraphViewModel.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 02/12/25.
//

import Foundation
import Combine
import SwiftUI

class GraphViewModel: ObservableObject {
    
    @Published var selectedRunUnit: RunUnits = .distance
    @Published var selectedTimeRange: GraphTimeRange = .week
    @Published var referenceDate: Date = Date()
    
    //MARK: - Funcs
    // Variável computada que filtra as corridas baseado na janela de tempo
        func filteredRuns(_ runs: [Run]) -> [Run] {
//            let calendar = Calendar.current
            guard let startDate = getStartDate() else { return [] }
            
            // Filtra corridas que estão entre startDate e referenceDate
            return runs.filter { run in
                return run.date >= startDate && run.date <= referenceDate
            }.sorted { $0.date < $1.date }
        }
        
        // Lógica para retroceder/avançar no tempo
        func moveTimeRange(direction: Int) {
            let calendar = Calendar.current
            let component: Calendar.Component
            let value: Int
            
            // Define o salto dependendo do filtro selecionado
            switch selectedTimeRange {
            case .week:
                component = .day
                value = 7 * direction
            case .month:
                component = .month
                value = 1 * direction
            case .threeMonths:
                component = .month
                value = 3 * direction
            case .sixMonths:
                component = .month
                value = 6 * direction
            case .year:
                component = .year
                value = 1 * direction
            }
            
            if let newDate = calendar.date(byAdding: component, value: value, to: referenceDate) {
                withAnimation {
                    referenceDate = newDate
                }
            }
        }
        
        // Calcula a data de início do gráfico
        func getStartDate() -> Date? {
            let calendar = Calendar.current
            switch selectedTimeRange {
            case .week:
                return calendar.date(byAdding: .day, value: -6, to: referenceDate) // 7 dias (incluindo hoje)
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: referenceDate)
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: referenceDate)
            case .sixMonths:
                return calendar.date(byAdding: .month, value: -6, to: referenceDate)
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: referenceDate)
            }
        }
        
        // Texto bonito para o Stepper (Ex: "Out 24 - 31")
        func getDateRangeLabel() -> String {
            guard let start = getStartDate() else { return "" }
            let formatter = DateFormatter()
            
            switch selectedTimeRange {
            case .week:
                formatter.dateFormat = "dd MMM"
                return "\(formatter.string(from: start)) - \(formatter.string(from: referenceDate))"
            case .month, .threeMonths, .sixMonths:
                formatter.dateFormat = "MMM yyyy"
                 // Se for mês, talvez mostrar só o mês atual se o range bater, mas para simplificar:
                if selectedTimeRange == .month {
                    return formatter.string(from: referenceDate)
                }
                return "\(formatter.string(from: start)) - \(formatter.string(from: referenceDate))"
            case .year:
                formatter.dateFormat = "yyyy"
                return formatter.string(from: referenceDate)
            }
        }
    
    func getChartBaseline(for runs: [Run]) -> Double {
        if selectedRunUnit == .pace {
            let maxVal = runs.map { $0.pace }.max() ?? 0
            return maxVal + 0.5
        } else {
            return 0
        }
    }
    
    
    func calculateAverage(for runs: [Run]) -> String {
        let values = runs.map { selectedRunUnit.value(of: $0) }
        let average = values.reduce(0, +) / Double(values.count)
        
        
        return getValueForMetric(average)
    }
    
    func calculateBest(for runs: [Run]) -> String {
        
        let values = runs.map { selectedRunUnit.value(of: $0) }
        let best: Double
        
        if selectedRunUnit == .pace {
            best = values.min() ?? 0
        } else {
            best = values.max() ?? 0
        }
        
        return getValueForMetric(best)
    }
    
    func calculateLast(for runs: [Run]) -> String {
        guard let last = runs.last else { return "N/A" }
        let lastValue = selectedRunUnit.value(of: last)
        
        return getValueForMetric(lastValue)
    }
    
    func getValueForMetric(_ metric: Double) -> String{
        switch selectedRunUnit {
        case .distance:
            return String(format: "%.2f", metric)
            
        case .durationMin:
            return metric.formatTimeHourMin()
            
        case .pace:
            return metric.toMinutesSeconds()
        }
    }

    
    
}
