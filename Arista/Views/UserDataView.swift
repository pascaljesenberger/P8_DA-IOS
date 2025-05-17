//
//  UserDataView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct UserDataView: View {
    @ObservedObject var viewModel: UserDataViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Hello")
                .font(.largeTitle)
            Text("\(viewModel.firstName) \(viewModel.lastName)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .alert("Erreur", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur inconnue est survenue.")
        }
    }
}
