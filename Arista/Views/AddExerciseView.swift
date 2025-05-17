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
    @State private var showErrorAlert = false
    @State private var selectedWheel: String = "Running"
    @State private var validationError = false
    
    private let wheelOptions = ["Running", "Natation", "Football", "Marche", "Cyclisme"]

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Picker("Catégorie", selection: $selectedWheel) {
                        ForEach(wheelOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: selectedWheel) { oldValue, newValue in
                        viewModel.wheel = newValue
                    }

                    DatePicker("Heure de démarrage", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)

                    Stepper(value: $viewModel.duration, in: 0...300) {
                        Text("Durée : \(viewModel.duration) minutes")
                    }

                    Stepper(value: $viewModel.intensity, in: 0...10) {
                        Text("Intensité : \(viewModel.intensity)")
                    }
                }
                .formStyle(.grouped)
                .onAppear {
                    viewModel.wheel = selectedWheel
                }

                Spacer()

                Button("Ajouter l'exercice") {
                    if viewModel.wheel.isEmpty || viewModel.duration <= 0 || viewModel.intensity <= 0 {
                        viewModel.error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Veuillez remplir tous les champs: catégorie, durée et intensité"])
                        showErrorAlert = true
                    } else {
                        let success = viewModel.addExercise()
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showErrorAlert = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Nouvel Exercice")
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Erreur"),
                    message: Text(viewModel.error?.localizedDescription ?? "Une erreur est survenue"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    AddExerciseView(viewModel: AddExerciseViewModel(context: PersistenceController.preview.container.viewContext))
}
