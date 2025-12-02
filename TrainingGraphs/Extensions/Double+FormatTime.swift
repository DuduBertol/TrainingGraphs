//
//  Double+Extension.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 04/11/25.
//

import Foundation

extension Double {
    func formatTime() -> String {
        let hours = Int(self) / 60
        let minutes = Int(self) % 60
        
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    func formatTimeHourMin() -> String {
        let hours = Int(self) / 60
        let minutes = Int(self) % 60
        
        return String(format: "%02dh%02dm", hours, minutes)
    }
    
    func toMinutesSeconds() -> String {
            let minutes = Int(self)
            let seconds = Int((self - Double(minutes)) * 60)
            return String(format: "%02d:%02d", minutes, seconds)
        }
}
