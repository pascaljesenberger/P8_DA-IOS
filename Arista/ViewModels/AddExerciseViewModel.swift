//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class AddExerciseViewModel: ObservableObject, ErrorHandling {
    @Published var wheel: String = ""
    @Published var startTime = Date()
    @Published var duration: Int = 0
    @Published var intensity: Int = 0
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addExercise() -> Bool {
        if wheel.isEmpty || duration <= 0 || intensity <= 0 {
            handleError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Veuillez remplir tous les champs: catégorie, durée et intensité"]), message: nil)
            return false
        }
        
        do {
            try ExerciseRepository(viewContext: context).addExercise(
                category: wheel,
                duration: duration,
                intensity: intensity,
                startDate: startTime
            )
            return true
        } catch {
            handleError(error, message: "Impossible d'ajouter l'exercice")
            return false
        }
    }
}
