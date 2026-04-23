//
//  ScoreStorageService.swift
//  Assignmen2
//
//  Created by Van Dao Le on 14/4/2026.
//

import Foundation
import Combine

/// Reactive persistence service for player high scores.
///
/// Declared as `@MainActor ObservableObject` so any SwiftUI view holding
/// a reference via `@EnvironmentObject` automatically re-renders when
/// `scores` changes — without needing manual `.onAppear` reloads.
/// Injected once at app level and shared across all screens.
@MainActor
class ScoreStorageService: ObservableObject {

    /// The sorted leaderboard. Views observe this directly — no manual reload needed.
    @Published private(set) var scores: [ScoreRecord] = []

    private let storageKey = "high_scores"

    init() {
        scores = loadFromDisk()
    }

    // MARK: – Computed Helpers

    /// The single highest recorded score across all players.
    var highestScore: Int {
        scores.first?.score ?? 0
    }

    // MARK: – Write

    /// Inserts or updates a player's best score, then re-sorts and persists the list.
    /// Only updates if the new `score` exceeds the player's existing record.
    func saveScore(playerName: String, score: Int) {
        if let index = scores.firstIndex(where: { $0.playerName == playerName }) {
            guard score > scores[index].score else { return }
            scores[index] = ScoreRecord(playerName: playerName, score: score)
        } else {
            scores.append(ScoreRecord(playerName: playerName, score: score))
        }
        scores.sort { $0.score > $1.score }
        saveToDisk()
    }

    // MARK: – Private Persistence

    private func loadFromDisk() -> [ScoreRecord] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        do {
            return try JSONDecoder().decode([ScoreRecord].self, from: data)
        } catch {
            return []
        }
    }

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(scores)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Non-fatal: previous data on disk remains unchanged.
        }
    }
}
