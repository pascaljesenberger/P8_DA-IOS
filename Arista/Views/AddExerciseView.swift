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

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Catégorie", text: $viewModel.category)

                    DatePicker("Heure de démarrage", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)

                    Stepper(value: $viewModel.duration, in: 0...300) {
                        Text("Durée : \(viewModel.duration) minutes")
                    }

                    Stepper(value: $viewModel.intensity, in: 0...10) {
                        Text("Intensité : \(viewModel.intensity)")
                    }
                }
                .formStyle(.grouped)

                Spacer()

                Button("Ajouter l'exercice") {
                    let success = viewModel.addExercise()
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        showErrorAlert = true
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
