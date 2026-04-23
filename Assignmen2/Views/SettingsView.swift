//
//  SettingsView.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import SwiftUI

/// Settings form enabling the user to customise their player name, game duration,
/// and maximum bubble count before starting a session.
///
/// `SettingsView` **owns** the `GamePlayViewModel` with `@StateObject`.
/// This is the correct pattern because:
/// - SettingsView is the entry point for a new game session
/// - `@StateObject` guarantees the VM is created exactly once and survives re-renders
/// - The VM is then passed **down** to `GameView` via `@ObservedObject` (explicit, readable)
struct SettingsView: View {

    /// `SettingsView` is the sole owner of this ViewModel.
    /// `@StateObject` ensures it is not recreated each time the view re-renders.
    @StateObject private var gameViewModel = GamePlayViewModel()

    // Internal navigation and alert states.
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var goToGame = false

    /// `true` when all input fields contain valid values.
    /// The Start button is disabled while this is `false`.
    private var isFormValid: Bool {
        let name = gameViewModel.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty && gameViewModel.countdown > 0 && gameViewModel.numberOfBubbles > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(.title)
                .bold()
                .padding(.vertical, 16)

            // MARK: – Player Name
            VStack(alignment: .leading, spacing: 4) {
                Text("Player Name")
                    .font(.headline)
                TextField("Enter your name", text: $gameViewModel.name)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            // MARK: – Game Timer
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Game Time")
                        .font(.headline)
                    Spacer()
                    Text("\(gameViewModel.countdown) sec")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                Slider(
                    value: Binding(
                        get: { Double(gameViewModel.countdown) },
                        set: {
                            gameViewModel.countdown = Int($0)
                            gameViewModel.totalTime = Int($0)
                        }
                    ),
                    in: 0...60,
                    step: 1
                )
                Text("Range: 0–60 seconds")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if gameViewModel.countdown == 0 {
                    Text("Game time must be at least 1 second.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            // MARK: – Maximum Bubbles
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Maximum Bubbles")
                        .font(.headline)
                    Spacer()
                    Text("\(gameViewModel.numberOfBubbles)")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                Slider(
                    value: Binding(
                        get: { Double(gameViewModel.numberOfBubbles) },
                        set: { gameViewModel.numberOfBubbles = Int($0) }
                    ),
                    in: 0...15,
                    step: 1
                )
                Text("Range: 0–15 bubbles")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if gameViewModel.numberOfBubbles == 0 {
                    Text("Maximum bubbles must be at least 1.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            Spacer()

            // MARK: – Start Button
            // Disabled (and visually dimmed) whenever any field is invalid,
            // so the user discovers errors without needing to tap Start first.
            Button {
                let trimmedName = gameViewModel.name.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedName.isEmpty {
                    alertTitle = "Missing Name"
                    alertMessage = "Please enter your name before starting the game."
                    showAlert = true
                } else {
                    gameViewModel.name = trimmedName
                    goToGame = true
                }
            } label: {
                MenuButtonView(title: "Start Game", color: isFormValid ? .green : .gray)
            }
            .disabled(!isFormValid)
            .padding(.bottom, 20)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        // Pass the owned VM explicitly to GameView — clear, readable data flow.
        .navigationDestination(isPresented: $goToGame) {
            GameView(gameViewModel: gameViewModel)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
