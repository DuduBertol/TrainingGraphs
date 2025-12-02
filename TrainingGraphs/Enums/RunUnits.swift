//
//  RunUnits.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 01/12/25.
//

import Foundation
import SwiftUI

enum RunUnits: String, CaseIterable {
    case distance = "Distance"
    case durationMin = "Duration"
    case pace = "Pace"
    
    var unit: String {
        switch self {
        case .distance: return "km"
        case .durationMin: return "min"
        case .pace: return "min/km"
        }
    }
    
    var color: Color {
        switch self {
        case .distance: return .blue
        case .durationMin: return .green
        case .pace: return .orange
        }
    }
    
    func value(of run: Run) -> Double {
        switch self {
        case .distance:
            return run.distanceKm
        case .durationMin:
            return Double(run.durationMin)
        case .pace:
            return run.pace
        }
    }
}
