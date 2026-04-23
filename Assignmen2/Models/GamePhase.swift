//
//  GamePhase.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import Foundation

/// Represents every discrete phase of a BubblePop game session.
///
/// Using a single enum instead of three separate `Bool` flags
/// (`showPreStart`, `gameOver`, `showGameOverScreen`) makes impossible
/// combinations — e.g. being simultaneously in countdown AND game-over —
/// unrepresentable at compile time.
enum GamePhase: Equatable, Sendable {
    /// The 3-2-1 countdown overlay is active before gameplay begins.
    /// `remaining` holds the number currently displayed on screen.
    case countdown(remaining: Int)

    /// Bubbles are spawning, the move timer is running, and the clock is ticking.
    case playing

    /// The timer reached zero; the game-over screen should be presented.
    case gameOver
}
