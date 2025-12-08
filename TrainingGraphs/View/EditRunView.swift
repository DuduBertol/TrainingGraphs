//
//  EditRunView.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 05/11/25.
//

import SwiftUI
import SwiftData

struct EditRunView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var run: Run
    
    @State var isPickerDatePresented: Bool = false
    @State var isPickerDurationPresented: Bool = false
    @State var isPickerDistancePresented: Bool = false
    let fractionalDistances = Array(stride(from: 0.0, through: 100.0, by: 0.25))
    
    @State var showConfirmDialog: Bool = false
    
    var body: some View {
        NavigationStack{
            Form{
                Section("Date") {
                    HStack{
                        Button{
                            isPickerDatePresented = true
                        } label: {
                            Text(run.date, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        }
                        .sheet(isPresented: $isPickerDatePresented) {
                            DatePicker("Select a Date", selection: $run.date)
                                .labelsHidden()
                                .datePickerStyle(.wheel)
                                .presentationDetents([
                                    .height(200)
                                ])
                        }
                        
                        
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                }
                
                Section("Duration (min)") {
                    HStack{
                        Button{
                            isPickerDurationPresented = true
                        } label: {
                            Text("\(Double(run.durationMin).formatTimeHourMin())")
                        }
                        .sheet(isPresented: $isPickerDurationPresented) {
                            Picker("Set Distance (km)", selection: $run.durationMin) {
                                ForEach(0..<241, id: \.self) { min in
                                    Text("\(Double(min).formatTimeHourMin())").tag(Double(min))
                                }
                            }
                            .pickerStyle(.wheel)
                            .presentationDetents([
                                .height(200)
                            ])
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                }
                
                Section("Distance (km)") {
                    HStack{
                        Button{
                            isPickerDistancePresented = true
                        } label: {
                            Text(String(format: "%.2f km", run.distanceKm))
                        }
                        .sheet(isPresented: $isPickerDistancePresented) {
                            Picker("Set Distance (km)", selection: $run.distanceKm) {
                                ForEach(fractionalDistances, id: \.self) { kms in
                                    Text(String(format: "%.2f km", kms))
                                        .tag(Double(kms))
                                }
                            }
                            .pickerStyle(.wheel)
                            .presentationDetents([
                                .height(150)
                            ])
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                }
                
                Section("Run Data") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("**\(String(format: "%.2f", run.distanceKm))** km")
                            .font(.title)
                        Text("\(Double(run.durationMin).formatTimeHourMin())")
                            .font(.title)
                        Text("**\(String(format: "%.2f", run.pace))** min/km")
                            .font(.headline)
                        Text(run.date, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                }
                
                // ⭐ Botão para salvar
                HStack {
                    Spacer()
                    Button {
                        saveChanges()
                    } label: {
                        Text("Save Changes")
                    }
                    .disabled(run.distanceKm == 0 || run.durationMin == 0)
                    Spacer()
                }
            }
            .navigationTitle("Edit Run")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Successfully Updated Run!", isPresented: $showConfirmDialog) {
                Button("OK") {
                    dismiss()
                }
            }
        }
    }
    
    private func saveChanges() {
    do {
        try context.save()
        showConfirmDialog = true
    } catch {
        print("Erro ao salvar alterações: \(error)")
    }
}
}

#Preview {
    EditRunView(run: Run(durationMin: 10, distanceKm: 2))
}
