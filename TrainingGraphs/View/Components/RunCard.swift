//
//  RunCard.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 04/11/25.
//

import SwiftUI

struct RunCard: View {
    
    @State var date: Date
    @State var durationMin: Int
    @State var distanceKm: Double
    @State var pace: Double
    
    var body: some View {
        //            ViewThatFits{
        VStack{
            HStack{
                Text(date, format: Date.FormatStyle(date: .abbreviated))
                    .padding(.vertical, 4)
                    .font(.footnote)
                Spacer()
            }
            
            
            HStack(spacing: 24){
//                Spacer()
                
                Text("\(distanceKm.format2F()) Km")
                    .font(.title)
                    .bold()
                
//                Spacer()
                
                Text("\(durationMin) min")
                    .font(.title2)
                
//                Spacer()
                
                Text("\(pace.toMinutesSeconds()) min/Km")
                    .font(.footnote)
                
//                Spacer()
                
            }
        }
    }
}

#Preview {
    RunCard(date: Date(), durationMin: 20, distanceKm: 3, pace: 5.5)
}
