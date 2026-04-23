//
//  GamePlayViewModel.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import Foundation
import Combine

/// ViewModel managing the entire lifecycle of a BubblePop game session,
/// including timers, bubble state, scoring, and persistence.
///
/// Marked `@MainActor` so all `@Published` property reads and writes
/// are guaranteed to happen on the main thread. This satisfies Swift 6
/// strict concurrency requirements and ensures SwiftUI updates are safe.
@MainActor
class GamePlayViewModel: ObservableObject {

    // MARK: – Published State

    @Published var name: String = ""
    @Published var score: Int = 0
    @Published var numberOfBubbles: Int = GameConstants.defaultMaxBubbles
    @Published var countdown: Int = GameConstants.defaultGameTime
    @Published var totalTime: Int = GameConstants.defaultGameTime
    @Published var lastPoppedBubbleType: BubbleType? = nil
    @Published var bubbles: [Bubble] = []

    /// Single source of truth for the current game phase.
    /// Replaces `showPreStart`, `preStartCount`, `gameOver`, and `showGameOverScreen`.
    @Published var phase: GamePhase = .countdown(remaining: GameConstants.countdownStart)

    // MARK: – Private Timers

    private var oneSecondTimer: Timer?
    private var moveTimer: Timer?
    private var preStartTimer: Timer?

    // MARK: – Bubble Management

    /// Refreshes the bubbles on screen according to the current play area constraints.
    func refreshBubbles(playWidth: CGFloat, playHeight: CGFloat) {
        bubbles = Utils.refreshBubbles(
            gamePlayWidth: playWidth,
            gamePlayHeight: playHeight,
            currentBubbles: bubbles,
            maximumBubble: numberOfBubbles
        )
    }

    // MARK: – Game Lifecycle

    /// Starts the 3-2-1 pre-game countdown sequence.
    /// Transitions phase: `.countdown(3)` → `.countdown(2)` → `.countdown(1)` → `.playing`
    func startPreStartCountdown(playWidth: CGFloat, playHeight: CGFloat) {
        guard countdown > 0, totalTime > 0, numberOfBubbles > 0 else {
            stopGame()
            return
        }

        phase = .countdown(remaining: GameConstants.countdownStart)
        preStartTimer?.invalidate()

        // Timer closure is nonisolated by default, so we hop back to
        // MainActor with Task { @MainActor in } before touching any
        // @Published property.
        // The outer closure parameter `timer` is not Sendable and cannot be
        // captured inside Task { @Sendable }. We use `self.preStartTimer`
        // (the stored reference) to invalidate instead — equivalent and safe.
        preStartTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }

                guard case .countdown(let remaining) = self.phase else {
                    self.preStartTimer?.invalidate()
                    return
                }

                if remaining > 1 {
                    self.phase = .countdown(remaining: remaining - 1)
                } else {
                    self.preStartTimer?.invalidate()
                    self.phase = .playing
                    self.startNewGame(playWidth: playWidth, playHeight: playHeight)
                }
            }
        }
    }

    /// Initialises the main game timers once the countdown finishes.
    /// One timer ticks the clock and refreshes bubbles each second;
    /// the other moves bubbles upward at approximately 60 FPS.
    func startNewGame(playWidth: CGFloat, playHeight: CGFloat) {
        refreshBubbles(playWidth: playWidth, playHeight: playHeight)
        oneSecondTimer?.invalidate()
        moveTimer?.invalidate()

        oneSecondTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.countdown -= 1
                if self.countdown <= 0 {
                    self.bubbles = []
                    self.stopGame()
                    return
                }
                self.refreshBubbles(playWidth: playWidth, playHeight: playHeight)
            }
        }

        moveTimer = Timer.scheduledTimer(
            withTimeInterval: GameConstants.deltaTime,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.phase == .playing else { return }
                self.bubbles = Utils.moveBubblesUp(
                    bubbles: self.bubbles,
                    timeLeft: self.countdown,
                    totalTime: self.totalTime
                )
            }
        }
    }

    /// Resets runtime state and restarts from the 3-2-1 countdown.
    func replay(playWidth: CGFloat, playHeight: CGFloat) {
        score = 0
        lastPoppedBubbleType = nil
        countdown = totalTime
        bubbles = []
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.preStartDelay) {
            Task { @MainActor [weak self] in
                self?.startPreStartCountdown(playWidth: playWidth, playHeight: playHeight)
            }
        }
    }

    /// Stops all timers and transitions to `.gameOver`.
    /// Score persistence is handled by the View layer via `onChange(of: phase)`.
    func stopGame() {
        oneSecondTimer?.invalidate()
        moveTimer?.invalidate()
        oneSecondTimer = nil
        moveTimer = nil
        phase = .gameOver
    }

    // MARK: – Scoring

    /// Handles a tap on a bubble: awards points, records combo, removes bubble.
    /// No-ops unless the game is in `.playing` phase.
    func handleBubbleTap(_ bubble: Bubble) {
        guard phase == .playing else { return }
        updateScore(for: bubble)
        bubbles.removeAll { $0.id == bubble.id }
    }

    /// Calculates the points awarded for popping a bubble.
    /// A `GameConstants.comboMultiplier` is applied when the bubble matches
    /// the previously popped type.
    func calculatePoints(for bubble: Bubble) -> Int {
        let basePoints = bubble.type.points
        if lastPoppedBubbleType == bubble.type {
            return Int((Double(basePoints) * GameConstants.comboMultiplier).rounded())
        }
        return basePoints
    }

    /// Updates the player's score and records the popped bubble type for combo tracking.
    func updateScore(for bubble: Bubble) {
        score += calculatePoints(for: bubble)
        lastPoppedBubbleType = bubble.type
    }

    /// Clears the current combo streak.
    func resetCombo() {
        lastPoppedBubbleType = nil
    }

    // MARK: – Full Reset

    /// Fully resets all game state, timers, and player data back to defaults.
    func reset() {
        oneSecondTimer?.invalidate()
        moveTimer?.invalidate()
        preStartTimer?.invalidate()
        oneSecondTimer = nil
        moveTimer = nil
        preStartTimer = nil

        phase = .countdown(remaining: GameConstants.countdownStart)
        score = 0
        name = ""
        lastPoppedBubbleType = nil
        numberOfBubbles = GameConstants.defaultMaxBubbles
        countdown = GameConstants.defaultGameTime
        totalTime = GameConstants.defaultGameTime
        bubbles = []
    }
}
