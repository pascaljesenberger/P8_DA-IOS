//
//  ErrorHandling.swift
//  Arista
//
//  Created by Pascal Jesenberger on 17/05/2025.
//

import Foundation

protocol ErrorHandling: AnyObject {
    var errorMessage: String? { get set }
    var showErrorAlert: Bool { get set }
}

extension ErrorHandling {
    func handleError(_ error: Error, message: String? = nil) {
        let errorText = message ?? error.localizedDescription
        errorMessage = "Une erreur est survenue : \(errorText)"
        showErrorAlert = true
    }
}
