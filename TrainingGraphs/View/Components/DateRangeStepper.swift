//
//  DateRangeStepper.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 04/12/25.
//

import SwiftUI

struct DateRangeStepper: View {
    @ObservedObject var vm: GraphViewModel
    
    var body: some View {
        HStack {
            Button {
                vm.moveTimeRange(direction: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline)
                    .padding(12)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(vm.getDateRangeLabel())
                .font(.subheadline)
                .monospacedDigit()
                .animation(.none, value: vm.referenceDate) // Evita animação estranha no texto
            
            Spacer()
            
            Button {
                vm.moveTimeRange(direction: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .padding(12)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(vm.referenceDate >= Date()) // Desabilita ir para o futuro além de hoje
            .opacity(vm.referenceDate >= Date() ? 0.3 : 1.0)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    DateRangeStepper(vm: GraphViewModel())
}
