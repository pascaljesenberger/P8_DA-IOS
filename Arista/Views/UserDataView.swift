//
//  UserDataView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct UserDataView: View {
    @ObservedObject var viewModel: UserDataViewModel
    
    private let greetings = [
        "Hello",
        "你好",
        "Hola",
        "Bonjour",
        "हैलो",
        "السلام عليكم",
        "Привет",
        "Olá",
        "안녕하세요",
        "こんにちは"
    ]
    
    @State private var currentIndex = 0
    @State private var animateOpacity = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(alignment: .center) {
            
            Spacer()
            
            Image("arista")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .padding(.vertical)
            
            Text(greetings[currentIndex])
                .font(.largeTitle)
                .opacity(animateOpacity ? 1 : 0)
                .animation(.easeInOut(duration: 1.0), value: animateOpacity)
                .onAppear {
                    animateOpacity = true
                    startTimer()
                }
                .onDisappear {
                    stopTimer()
                }
            
            Text("\(viewModel.firstName) \(viewModel.lastName)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.customPink)
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
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
            withAnimation {
                animateOpacity = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                var newIndex: Int
                repeat {
                    newIndex = Int.random(in: 0..<greetings.count)
                } while newIndex == currentIndex // éviter répétition
                
                currentIndex = newIndex
                
                withAnimation {
                    animateOpacity = true
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
