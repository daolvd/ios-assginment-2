//
//  HighScoreView.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import SwiftUI

/// A dedicated screen listing the all-time Top 5 high scores, sorted by points descending.
///
/// Reads from `ScoreStorageService` via `@EnvironmentObject` — the list
/// is always current and re-renders automatically when new scores are saved.
struct HighScoreView: View {

    /// Reactive score data shared across the app via environment injection.
    @EnvironmentObject private var scoreService: ScoreStorageService

    var body: some View {
        VStack {
            if scoreService.scores.isEmpty {
                // Empty state shown before any game has been played.
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 56))
                        .foregroundColor(.orange.opacity(0.5))
                    Text("No scores yet")
                        .font(.title3.bold())
                        .foregroundColor(.secondary)
                    Text("Play a game to get on the board!")
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
        }
        .navigationTitle("High Scores")
        // No .onAppear reload needed — scoreService.scores is @Published
        // and SwiftUI will re-render this view automatically when it changes.
    }
}

#Preview {
    NavigationStack {
        HighScoreView()
            .environmentObject(ScoreStorageService())
    }
}
