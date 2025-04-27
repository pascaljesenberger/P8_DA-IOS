//
//  UserRepository.swift
//  Arista
//
//  Created by Pascal Jesenberger on 27/04/2025.
//

import Foundation
import CoreData

struct UserRepository {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    func getUser() throws -> User? {
        let request = User.fetchRequest()
        request.fetchLimit = 1
        return try viewContext.fetch(request).first
    }
}
