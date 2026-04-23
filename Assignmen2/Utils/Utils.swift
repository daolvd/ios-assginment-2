//
//  Utils.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import Foundation

/// Stateless utility functions for bubble placement and movement logic.
/// Declared as an `enum` (not a `class`) to serve as a pure namespace —
/// it cannot be accidentally instantiated.
enum Utils {

    /// Refreshes the bubbles on screen by randomly removing some existing ones
    /// and spawning new ones up to the configured maximum count.
    /// - Parameters:
    ///   - gamePlayWidth: Width of the playable area in points.
    ///   - gamePlayHeight: Height of the playable area in points.
    ///   - currentBubbles: The bubbles currently displayed on screen.
    ///   - maximumBubble: The maximum number of bubbles allowed at once.
    /// - Returns: An updated array of bubbles for the next render cycle.
    static func refreshBubbles(
        gamePlayWidth: CGFloat,
        gamePlayHeight: CGFloat,
        currentBubbles: [Bubble],
        maximumBubble: Int
    ) -> [Bubble] {
        guard maximumBubble > 0 else { return [] }

        let targetCount = Int.random(in: 1...maximumBubble)
        var bubbles = currentBubbles.shuffled()

        // Randomly remove some existing bubbles, but never all of them at once.
        // Upper bound is (count - 1) to guarantee at least one bubble survives
        // the removal step before new ones are added.
        if bubbles.count > 1 {
            let removeCount = Int.random(in: 0...(bubbles.count - 1))
            bubbles.removeFirst(removeCount)
        }

        // Spawn new bubbles until the target count is reached or no valid
        // position can be found within the allowed attempts.
        while bubbles.count < targetCount {
            guard let position = findValidPosition(
                gamePlayWidth: gamePlayWidth,
                gamePlayHeight: gamePlayHeight,
                bubbleRadius: GameConstants.bubbleSize / 2,
                currentBubbles: bubbles
            ) else {
                break
            }
            bubbles.append(Bubble(type: randomType(), x: position.x, y: position.y))
        }

        return bubbles
    }

    /// Moves bubbles upward each frame. Speed increases progressively as
    /// the remaining time decreases, adding urgency towards the end of the game.
    /// - Parameters:
    ///   - bubbles: The current list of active bubbles.
    ///   - timeLeft: Remaining game time in seconds.
    ///   - totalTime: Total game duration configured in settings.
    /// - Returns: Updated bubbles with adjusted y-coordinates.
    static func moveBubblesUp(bubbles: [Bubble], timeLeft: Int, totalTime: Int) -> [Bubble] {
        let progress = CGFloat(totalTime - timeLeft) / CGFloat(totalTime)
        let speed = GameConstants.baseSpeed + progress * GameConstants.maxSpeedBonus

        return bubbles.map { bubble in
            var updated = bubble
            updated.y -= speed * GameConstants.deltaTime
            return updated
        }
    }

    /// Returns a random `BubbleType` weighted by each type's spawn probability following the table in assignment.
    /// - Returns: A randomly selected `BubbleType`.
    static func randomType() -> BubbleType {
        let roll = Int.random(in: 1...100)
        switch roll {
        case 1...40:  return .red
        case 41...70: return .pink
        case 71...85: return .green
        case 86...95: return .blue
        default:      return .black
        }
    }

    /// Attempts to find a coordinate for a new bubble that does not overlap
    /// existing bubbles and lies fully within the play area boundaries.
    /// - Parameters:
    ///   - gamePlayWidth: Width of the playable area in points.
    ///   - gamePlayHeight: Height of the playable area in points.
    ///   - bubbleRadius: Radius of the bubble to place.
    ///   - currentBubbles: Existing bubbles to check against for overlap.
    /// - Returns: A valid `CGPoint`, or `nil` if no position was found within
    ///   `GameConstants.maxPlacementAttempts` tries.
    static func findValidPosition(
        gamePlayWidth: CGFloat,
        gamePlayHeight: CGFloat,
        bubbleRadius: CGFloat,
        currentBubbles: [Bubble]
    ) -> CGPoint? {
        for _ in 0..<GameConstants.maxPlacementAttempts {
            let x = CGFloat.random(in: bubbleRadius...(gamePlayWidth - bubbleRadius))
            let y = CGFloat.random(in: bubbleRadius...(gamePlayHeight - bubbleRadius))
            if !isOverlapping(x: x, y: y, radius: bubbleRadius, bubbles: currentBubbles) {
                return CGPoint(x: x, y: y)
            }
        }
        return nil
    }

    /// Returns `true` if the proposed position overlaps with any existing bubble.
    /// Two bubbles overlap when the distance between their centres is less than
    /// two radii (i.e., their circles intersect).
    /// - Parameters:
    ///   - x: Proposed centre x-coordinate.
    ///   - y: Proposed centre y-coordinate.
    ///   - radius: Radius of the bubble being placed.
    ///   - bubbles: The list of already-placed bubbles.
    /// - Returns: `true` if any overlap is detected.
    static func isOverlapping(x: CGFloat, y: CGFloat, radius: CGFloat, bubbles: [Bubble]) -> Bool {
        bubbles.contains { bubble in
            let dx = x - bubble.x
            let dy = y - bubble.y
            return sqrt(dx * dx + dy * dy) < radius * 2
        }
    }
}
