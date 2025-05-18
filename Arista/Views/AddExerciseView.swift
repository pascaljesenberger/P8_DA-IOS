//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddExerciseViewModel
    @State private var selectedWheel: String = "Running"
    
    private let wheelOptions = ["Running", "Natation", "Football", "Marche", "Cyclisme"]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        Picker("Catégorie", selection: $selectedWheel) {
                            ForEach(wheelOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .onChange(of: selectedWheel) { oldValue, newValue in
                            viewModel.wheel = newValue
                        }
                    
                        DatePicker("Heure de démarrage", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Section {
                        HStack {
                            Text("Durée")
                            Spacer()
                            Text("\(viewModel.duration) minutes")
                        }
                        
                        Slider(value: Binding(
                            get: { Double(viewModel.duration) },
                            set: { viewModel.duration = Int($0) }
                        ), in: 5...180, step: 5)
                        
                        HStack {
                            Text("Intensité")
                            Spacer()
                            Text("\(viewModel.intensity)/10")
                        }
                        
                        Slider(value: Binding(
                            get: { Double(viewModel.intensity) },
                            set: { viewModel.intensity = Int($0) }
                        ), in: 1...10, step: 1)
                    }
                }
                .formStyle(.grouped)
                .onAppear {
                    selectedWheel = viewModel.wheel
                }
                
                Button("Ajouter l'exercice") {
                    if viewModel.validateFields() {
                        if viewModel.addExercise() {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        viewModel.handleError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Veuillez vérifier tous les champs"]), message: nil)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Nouvel Exercice")
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(
                    title: Text("Erreur"),
                    message: Text(viewModel.errorMessage ?? "Une erreur est survenue"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    AddExerciseView(viewModel: AddExerciseViewModel(context: PersistenceController.preview.container.viewContext))
}
