//
//  ScoreRecord.swift
//  Assignmen2
//
//  Created by Van Dao Le on 14/4/2026.
//

import Foundation

/// A single player high-score entry stored in persistent storage.
struct ScoreRecord: Codable, Identifiable {
    /// Stable unique identifier persisted alongside the record.
    /// Using `let` prevents mutation after creation, and the explicit
    /// `init` ensures the UUID is encoded/decoded correctly so identity
    /// remains stable across app launches.
    let id: UUID
    let playerName: String
    let score: Int

    init(playerName: String, score: Int) {
        self.id = UUID()
        self.playerName = playerName
        self.score = score
    }
}
