//
//  HistoryView.swift
//  TrainingGraphs
//
//  Created by Eduardo Bertol on 29/10/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
//    let runs = Run.mockArrayRuns()
    
    @State private var selectedRun: Run?
    
    @State var showDeleteAllRunsAlert: Bool = false
    @State var showConfirmDeleteDialog: Bool = false

    @State var runToDelete: Run?
    @State var showDeleteRunAlert: Bool = false
    
    
    var body: some View {
        VStack(spacing: 16){
            Text("History")
                .font(.title)
                .bold()
                .foregroundStyle(.opacity(0.5))
                .padding()
            
            VStack{
                
                List {
                    ForEach(runs){ run in
    //                    VStack{
    //                        Text(run.date.description)
    //                        Text("\(run.durationMin)")
    //                        Text("\(run.distanceKm)")
    //                    }
    //
                        RunCard(date: run.date, durationMin: run.durationMin, distanceKm: run.distanceKm, pace: run.pace)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button{
                                    selectedRun = run
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .confirmationDialog("Are you sure you want to delete this run?", isPresented: $showDeleteRunAlert, titleVisibility: .visible) {
                                Button("Delete Run", role: .destructive) {
                                    guard let run = runToDelete else { return }

                                    do {
                                        context.delete(run)
                                        try context.save()
                                        runToDelete = nil
                                        
                                        showConfirmDeleteDialog = true
                                    } catch {
                                        print("Erro ao deletar os dados: \(error)")
                                    }
                                }
                                .alert("Successfully Deleted All Runs!", isPresented: $showConfirmDeleteDialog) {}
                                
                            } message: {
                                Text("This action is permanent and cannot be undone.")
                            }
                    }
                    .onDelete{ indexSet in
                        indexSet.forEach{ index in
                            runToDelete = runs[index]
                            showDeleteRunAlert = true
                        }
                    }
                    
                    Spacer()
                    
                    deleteAllButton()
                }
//                .scrollContentBackground(.hidden)
//                .listStyle(.plain)
                .sheet(item: $selectedRun) { run in
                    EditRunView(run: run)
                }
                

                
                
            }
            .padding(.bottom, 32)
        }
    }
    
    func deleteAllButton() -> some View{
        HStack{
            Spacer()
            Button(role: .destructive) {
                showDeleteAllRunsAlert = true
            } label: {
                Text("Delete all runs")
            }
            .confirmationDialog("Are you sure you want to delete all runs?",
                                isPresented: $showDeleteAllRunsAlert,
                                titleVisibility: .visible) {
                Button("Delete All Runs", role: .destructive) {
                    do {
                        try context.delete(model: Run.self)
                        try context.save()
                        
                        showConfirmDeleteDialog = true
                    } catch {
                        print("Erro ao deletar os dados: \(error)")
                    }
                }
                .alert("Successfully Deleted All Runs!", isPresented: $showConfirmDeleteDialog) {}
                
            } message: {
                Text("This action is permanent and cannot be undone.")
            }
            
            
            Spacer()
        }
    }
}

#Preview {
    HistoryView()
}
