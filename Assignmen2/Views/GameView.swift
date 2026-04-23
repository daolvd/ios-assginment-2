//
//  GameView.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import SwiftUI

/// The main gameplay screen displaying the bubble play area and the top score bar.
///
/// - `gameViewModel` is received from `SettingsView` via `@ObservedObject`.
/// - `scoreService` is read from the environment (injected by `Assignmen2App`).
///   This avoids prop-drilling and lets the view react to score changes automatically.
struct GameView: View {
    /// Allows the view to pop back to the settings screen when the player chooses Home.
    @Environment(\.dismiss) private var dismiss

    /// The game ViewModel owned by `SettingsView`, passed in explicitly.
    @ObservedObject var gameViewModel: GamePlayViewModel

    /// Shared score service from the app environment.
    /// Observing this directly means `bestScore` in the top bar updates reactively
    /// without a separate `@State` variable or manual `.onAppear` reload.
    @EnvironmentObject private var scoreService: ScoreStorageService

    var body: some View {
        GeometryReader { geometry in
            let topBarHeight: CGFloat = 80
            let rawWidth = geometry.size.width
            let rawHeight = geometry.size.height - topBarHeight
            let playWidth = max(0, rawWidth.isFinite ? rawWidth : 0)
            let playHeight = max(0, rawHeight.isFinite ? rawHeight : 0)

            VStack(spacing: 0) {
                // MARK: – Top Bar
                HStack {
                    Text("Time: \(gameViewModel.countdown)")
                        .font(.headline)
                        .padding(10)
                    Spacer()
                    // Reads directly from scoreService — no @State bestScore needed.
                    Text("Best: \(scoreService.highestScore)")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .padding(10)
                    Spacer()
                    Text("Score: \(gameViewModel.score)")
                        .font(.headline)
                        .padding(10)
                }
                .frame(height: topBarHeight)

                // MARK: – Play Area
                ZStack {
                    Color.white

                    ForEach(gameViewModel.bubbles) { bubble in
                        BubbleView(
                            bubble: bubble,
                            isCombo: gameViewModel.lastPoppedBubbleType == bubble.type
                        ) {
                            gameViewModel.handleBubbleTap(bubble)
                        }
                        .position(x: bubble.x, y: bubble.y)
                    }

                    // Pre-start countdown overlay — visible only during `.countdown` phase.
                    if case .countdown(let remaining) = gameViewModel.phase {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()
                        Text("\(remaining)")
                            .font(.system(size: 120, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: playWidth, height: playHeight)
                .clipped()
                .onAppear {
                    gameViewModel.startPreStartCountdown(playWidth: playWidth, playHeight: playHeight)
                }
            }
            .navigationBarBackButtonHidden(true)
            // Save score the moment the game ends, before GameOverView appears.
            // Using onChange keeps persistence out of the ViewModel.
            .onChange(of: gameViewModel.phase) { _, newPhase in
                if case .gameOver = newPhase {
                    scoreService.saveScore(
                        playerName: gameViewModel.name,
                        score: gameViewModel.score
                    )
                }
            }
            // Game-over sheet bridged from GamePhase enum to Bool.
            .fullScreenCover(isPresented: Binding(
                get: { gameViewModel.phase == .gameOver },
                set: { _ in }
            )) {
                GameOverView(
                    playerName: gameViewModel.name,
                    score: gameViewModel.score,
                    onHome: {
                        gameViewModel.reset()
                        dismiss()
                    },
                    onReplay: {
                        gameViewModel.replay(playWidth: playWidth, playHeight: playHeight)
                    }
                )
            }
        }
    }
}

#Preview {
    GameView(gameViewModel: GamePlayViewModel())
        .environmentObject(ScoreStorageService())
}
