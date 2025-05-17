//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    @State private var showingAddExerciseView = false

    var body: some View {
        NavigationView {
            List(viewModel.exercises) { exercise in
                HStack {
                    Image(systemName: iconForCategory(exercise.category ?? ""))
                    VStack(alignment: .leading) {
                        Text(exercise.category ?? "Inconnu")
                            .font(.headline)
                        Text("Durée: \(Int(exercise.duration)) min")
                            .font(.subheadline)
                        if let date = exercise.startDate {
                            Text(date.formatted())
                                .font(.subheadline)
                        } else {
                            Text("Date inconnue")
                                .font(.subheadline)
                        }
                    }
                    Spacer()
                    IntensityIndicator(intensity: Int(exercise.intensity))
                }
            }
            .navigationTitle("Exercices")
            .navigationBarItems(trailing: Button(action: {
                showingAddExerciseView = true
            }) {
                Image(systemName: "plus")
            })
            .alert("Erreur", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Une erreur inconnue est survenue.")
            }
        }
        .sheet(isPresented: $showingAddExerciseView, onDismiss: {
            viewModel.reload()
        }) {
            AddExerciseView(viewModel: AddExerciseViewModel(context: viewModel.viewContext))
        }
        .onAppear {
            viewModel.reload()
        }
    }

    func iconForCategory(_ category: String) -> String {
        switch category {
        case "Football":
            return "sportscourt"
        case "Natation":
            return "waveform.path.ecg"
        case "Running":
            return "figure.run"
        case "Marche":
            return "figure.walk"
        case "Cyclisme":
            return "bicycle"
        default:
            return "questionmark"
        }
    }
}

struct IntensityIndicator: View {
    var intensity: Int

    var body: some View {
        Circle()
            .fill(colorForIntensity(intensity))
            .frame(width: 10, height: 10)
    }

    func colorForIntensity(_ intensity: Int) -> Color {
        switch intensity {
        case 0...3:
            return .green
        case 4...6:
            return .yellow
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    ExerciseListView(viewModel: ExerciseListViewModel(context: PersistenceController.preview.container.viewContext))
}
