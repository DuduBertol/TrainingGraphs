//
//  RunTrain.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 29/10/25.
//

import Foundation
import SwiftData

@Model
class Run {
    var id: UUID
    var date: Date
    var durationMin: Int
    var distanceKm: Double
    var pace: Double {
        distanceKm > 0 ? Double(durationMin) / distanceKm : 0
    }
     
    
    init(date: Date = Date(), durationMin: Int, distanceKm: Double) {
        self.id = UUID()
        self.date = date
        self.durationMin = durationMin
        
        self.distanceKm = distanceKm
    }
}

//MOCKS
extension Run {
    static func mockRun() -> Run {
        Run(date: Date(), durationMin: 60, distanceKm: 10.0)
    }
    
    static func mockArrayRunsSameDate() -> [Run] {
        [
            Run(durationMin: 60, distanceKm: 6),
            Run(durationMin: 60, distanceKm: 9),
            Run(durationMin: 60, distanceKm: 3),
            Run(durationMin: 60, distanceKm: 15),
            Run(durationMin: 60, distanceKm: 5),
            Run(durationMin: 60, distanceKm: 6),
            Run(durationMin: 60, distanceKm: 8),
            Run(durationMin: 60, distanceKm: 5),
            Run(durationMin: 60, distanceKm: 15),
            Run(durationMin: 60, distanceKm: 1),
        ]
    }
    
    static func mockArrayRuns() -> [Run] {
        [
            // --- HOJE E ÚLTIMOS 7 DIAS (24 Nov - 01 Dez) ---
            Run(
                date: Date.dateCreator(year: 2025, month: 12, day: 1), // Hoje
                durationMin: 45,
                distanceKm: 8.0
            ),
            Run(
                date: Date.dateCreator(year: 2025, month: 11, day: 29), // 2 dias atrás
                durationMin: 60,
                distanceKm: 10.0
            ),
            Run(
                date: Date.dateCreator(year: 2025, month: 11, day: 26), // 5 dias atrás
                durationMin: 30,
                distanceKm: 5.0
            ),
            
            // --- ÚLTIMOS 15 DIAS (09 Nov - 23 Nov) ---
            // Estas aparecerão no filtro de 15, 30 e 60, mas NÃO no de 7
            Run(
                date: Date.dateCreator(year: 2025, month: 11, day: 20),
                durationMin: 90, // Longão
                distanceKm: 15.0
            ),
            Run(
                date: Date.dateCreator(year: 2025, month: 11, day: 17),
                durationMin: 50,
                distanceKm: 9.0
            ),

            // --- ÚLTIMOS 30 DIAS (01 Nov - 16 Nov) ---
            // Estas aparecerão no filtro de 30 e 60, mas NÃO no de 15
            Run(
                date: Date.dateCreator(year: 2025, month: 11, day: 10),
                durationMin: 55,
                distanceKm: 10.0
            ),
            Run(
                date: Date.dateCreator(year: 2025, month: 11, day: 5),
                durationMin: 40,
                distanceKm: 7.0
            ),
            
            // --- ÚLTIMOS 60 DIAS (Outubro) ---
            // Estas aparecerão APENAS no filtro de 60 dias
            Run(
                date: Date.dateCreator(year: 2025, month: 10, day: 25),
                durationMin: 120, // Meia Maratona treino
                distanceKm: 21.0
            ),
            Run(
                date: Date.dateCreator(year: 2025, month: 10, day: 15),
                durationMin: 60,
                distanceKm: 11.0
            ),
            Run(
                date: Date.dateCreator(year: 2025, month: 10, day: 5),
                durationMin: 45,
                distanceKm: 8.5
            ),
            
            // --- FORA DO FILTRO (> 60 dias) ---
            // Setembro - Não deve aparecer em nenhum filtro atual
            Run(
                date: Date.dateCreator(year: 2025, month: 9, day: 15),
                durationMin: 45,
                distanceKm: 7.0
            )
        ]
    }
}

extension Run {
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

extension Date {
    static func dateCreator(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }
}


