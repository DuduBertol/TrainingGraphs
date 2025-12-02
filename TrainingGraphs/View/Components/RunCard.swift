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
            HStack(spacing: 8){
                Spacer()
                
                Text("\(distanceKm.format2F()) Km")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Text("\(durationMin) min")
                    .font(.title2)

                Spacer()
                
                VStack(alignment: .leading){
                    Text("\(pace.toMinutesSeconds()) min/Km")
                        .font(.footnote)
                    Spacer()
                    Text(date, format: Date.FormatStyle(date: .abbreviated))
                        .font(.footnote)
                }
                Spacer()
            }
            .frame(maxHeight: 75)
    }
}

#Preview {
    RunCard(date: Date(), durationMin: 20, distanceKm: 3, pace: 5.5)
}
