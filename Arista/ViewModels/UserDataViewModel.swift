//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class UserDataViewModel: ObservableObject, ErrorHandling {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchUserData()
    }
    
    private func fetchUserData() {
        do {
            guard let user = try UserRepository().getUser() else {
                handleError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Données utilisateur non trouvées"]), message: nil)
                return
            }
            firstName = user.firstName ?? ""
            lastName = user.lastName ?? ""
        } catch {
            handleError(error, message: "Impossible de charger les données utilisateur")
        }
    }
}
