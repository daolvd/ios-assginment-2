//
//  BubbleView.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import SwiftUI

/// A reusable graphical component representing a single interactive bubble.
struct BubbleView: View {
    /// The data model containing the bubble's coordinates and type.
    var bubble: Bubble

    @State private var isVisible: Bool = false
    @State private var isPopping: Bool = false
    /// Briefly true during the tap-down bounce before the pop animation starts.
    /// Gives clear visual feedback that the tap registered — visible on simulator too.
    @State private var isPressing: Bool = false

    /// Whether this specific bubble was popped as part of a consecutive colour combo.
    /// Captured at the moment of tap so only the tapped bubble shows combo feedback.
    var isCombo: Bool


    // Internal animation state for the floating score effect.
    @State private var effectOffsetY: CGFloat = 0
    @State private var effectOpacity: Double = 0

    /// Stores whether a combo was active at the exact moment this bubble was tapped.
    /// Using a local copy ensures only the tapped bubble shows combo text, not every
    /// bubble of the same colour still on screen.
    @State private var comboActiveAtTap: Bool = false

    var onTap: () -> Void = {}

    var body: some View {
        ZStack {
            Button(action: {
                // Haptic feedback on real device (silent on simulator — see bounce below).
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                // Visual bounce: scale up briefly before popping.
                // This is visible on simulator and reinforces the tap on device.
                comboActiveAtTap = isCombo
                withAnimation(.easeOut(duration: 0.08)) { isPressing = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    isPressing = false
                    onPopOut()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.popRemovalDelay) {
                    onTap()
                }
            }) {
                Circle()
                    .frame(width: GameConstants.bubbleSize, height: GameConstants.bubbleSize)
                    .foregroundColor(bubble.type.color)
                    .scaleEffect(
                        isPopping  ? 0.1  :
                        isPressing ? 1.25 :
                        isVisible  ? 1.0  : 0.1,
                        anchor: .center
                    )
                    .opacity(isPopping ? 0 : 1)
            }
            .onAppear {
                withAnimation(.easeOut(duration: GameConstants.bubbleAppearDuration)) {
                    isVisible = true
                }
            }

            // Floating score feedback shown only while the pop animation is playing.
            if isPopping {
                VStack(spacing: 4) {
                    let displayPoints = comboActiveAtTap
                        ? Int((Double(bubble.type.points) * GameConstants.comboMultiplier).rounded())
                        : bubble.type.points

                    Text("+\(displayPoints)")
                        .font(.largeTitle.bold())
                        .foregroundColor(bubble.type.color)
                        .shadow(color: .black, radius: 0, x: 1, y: 1)

                    if comboActiveAtTap {
                        Text("Combo ×\(String(format: "%.1f", GameConstants.comboMultiplier))")
                            .font(.title.bold())
                            .foregroundColor(bubble.type.color)
                            .shadow(color: .black, radius: 0, x: 1, y: 1)
                    }
                }
                .offset(y: effectOffsetY)
                .opacity(effectOpacity)
            }
        }
    }

    /// Triggers the pop-out shrink and floating score animation.
    private func onPopOut() {
        isPopping = true
        effectOffsetY = 0
        effectOpacity = 1
        withAnimation(.easeOut(duration: GameConstants.popAnimationDuration)) {
            effectOffsetY = -40
            effectOpacity = 0
        }
    }
}

#Preview {
    BubbleView(bubble: Bubble(type: .green, x: 50, y: 50), isCombo: false)
}
