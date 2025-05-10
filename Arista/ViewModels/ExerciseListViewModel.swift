//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class ExerciseListViewModel: ObservableObject {
    @Published var exercises = [Exercise]()
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false

    var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExercises()
    }

    private func fetchExercises() {
        do {
            let data = ExerciseRepository(viewContext: viewContext)
            exercises = try data.getExercise()
        } catch {
            errorMessage = "Une erreur est survenue lors du chargement des exercices : \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
