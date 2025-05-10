//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData
import SwiftUI

class SleepHistoryViewModel: ObservableObject {
    @Published var sleepSessions = [Sleep]()
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchSleepSessions()
    }

    private func fetchSleepSessions() {
        do {
            let data = SleepRepository(viewContext: viewContext)
            sleepSessions = try data.getSleepSessions()
        } catch {
            errorMessage = "Une erreur est survenue lors du chargement des données : \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
