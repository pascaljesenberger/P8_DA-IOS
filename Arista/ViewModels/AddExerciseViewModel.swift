//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class AddExerciseViewModel: ObservableObject, ErrorHandling {
    @Published var wheel: String = "Running"
    @Published var startTime = Date()
    @Published var duration: Int = 30
    @Published var intensity: Int = 5
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addExercise() -> Bool {
        if wheel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            handleError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "La catégorie ne peut pas être vide"]), message: nil)
            return false
        }
        
        if duration <= 0 {
            handleError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "La durée doit être supérieure à 0"]), message: nil)
            return false
        }
        
        if intensity <= 0 {
            handleError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "L'intensité doit être supérieure à 0"]), message: nil)
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
    
    func validateFields() -> Bool {
        if wheel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || duration <= 0 || intensity <= 0 {
            return false
        }
        return true
    }
}
