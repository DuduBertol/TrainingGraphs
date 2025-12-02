//
//  DateRange.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 01/12/25.
//

import Foundation

enum DateRange: Int, CaseIterable {
    case week = 7
    case twoWeeks = 15
    case month = 30
    case twoMonths = 60
    
    var title: String {
        return "\(rawValue) Dias" // Ex: "7 Dias"
    }
    
//    var runsOnPeriod
}
