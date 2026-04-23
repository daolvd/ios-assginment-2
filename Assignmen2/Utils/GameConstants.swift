//
//  GameConstants.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import Foundation

/// Central repository for all game-wide constants.
/// To tune gameplay, modify values here — no need to touch logic files.
enum GameConstants {

    // MARK: – Default Settings

    /// Default game duration in seconds.
    static let defaultGameTime: Int = 60
    /// Default maximum number of bubbles on screen.
    static let defaultMaxBubbles: Int = 15
    /// Starting value for the pre-game countdown overlay.
    static let countdownStart: Int = 3
    /// Delay before the pre-start countdown begins after a replay.
    static let preStartDelay: Double = 0.3

    // MARK: – Bubble Physics

    /// Diameter of every bubble in points.
    static let bubbleSize: Double = 80
    /// Base upward speed of bubbles in points per second.
    static let baseSpeed: Double = 40
    /// Additional speed bonus added as the game time decreases (max urgency).
    static let maxSpeedBonus: Double = 80
    /// Target frame rate for the move timer.
    static let frameRate: Double = 60
    /// Time step per frame, derived from the target frame rate.
    static let deltaTime: Double = 1.0 / frameRate

    // MARK: – Bubble Placement

    /// Maximum random placement attempts before giving up on a new bubble position.
    static let maxPlacementAttempts: Int = 200

    // MARK: – Scoring

    /// Score multiplier applied when two consecutive bubbles of the same colour are popped.
    static let comboMultiplier: Double = 1.5

    // MARK: – Animation

    /// Duration of the bubble pop shrink animation.
    static let popAnimationDuration: Double = 0.4
    /// Delay between the pop animation starting and the bubble being removed from state.
    static let popRemovalDelay: Double = 0.2
    /// Duration of the bubble fade-in animation on spawn.
    static let bubbleAppearDuration: Double = 0.2
}
