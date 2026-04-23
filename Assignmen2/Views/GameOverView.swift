//
//  GameOverView.swift
//  Assignmen2
//
//  Created by Van Dao Le on 14/4/2026.
//

import SwiftUI

/// Modal screen displayed when the game timer reaches zero, summarising the player's
/// performance and showing the global Top 5 leaderboard.
///
/// Reads scores directly from `ScoreStorageService` via `@EnvironmentObject` —
/// the list is always up-to-date without a manual `.onAppear` reload.
struct GameOverView: View {
    let playerName: String
    let score: Int

    /// Callback invoked when the player returns to the home screen.
    var onHome: () -> Void
    /// Callback invoked when the player restarts immediately.
    var onReplay: () -> Void

    /// Reactive score data from the environment. Updates automatically when a new
    /// score is saved (triggered by `GameView.onChange(of: phase)`).
    @EnvironmentObject private var scoreService: ScoreStorageService

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)

            Text("Game Over")
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(.gray)
                .padding(.top, 10)

            Text("\(playerName):  \(score)")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.black)
                .padding(.top, 24)

            Spacer()
                .frame(height: 24)

            HStack {
                sectionTitle(
                    text: "Best score: \(scoreService.highestScore)",
                    textColor: .orange
                )
            }

            Spacer()
                .frame(height: 12)

            Text("High Scores")
                .bold()
                .font(.largeTitle.bold())

            // Leaderboard — reads reactively from scoreService.scores (no onAppear needed).
            if scoreService.scores.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.orange.opacity(0.5))
                    Text("No scores recorded yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(Array(scoreService.scores.prefix(5).enumerated()), id: \.element.id) { index, item in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.headline)
                                .frame(width: 45, alignment: .leading)
                            Text(item.playerName)
                                .font(.body)
                            Spacer()
                            Text("\(item.score)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
            }

            HStack(spacing: 36) {
                circleButton(backgroundColor: .green, systemImage: "house.fill", action: onHome)
                circleButton(backgroundColor: .pink.opacity(0.7), systemImage: "arrow.counterclockwise", action: onReplay)
            }
            .padding(.top, 10)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }

    @ViewBuilder
    private func sectionTitle(text: String, textColor: Color) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.8))
                .frame(height: 64)
            Text(text)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(textColor)
        }
    }

    @ViewBuilder
    private func circleButton(backgroundColor: Color, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 96, height: 96)
                    .shadow(radius: 2)
                Image(systemName: systemImage)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameOverView(
        playerName: "Kimi",
        score: 65,
        onHome: {},
        onReplay: {}
    )
    .environmentObject(ScoreStorageService())
}
