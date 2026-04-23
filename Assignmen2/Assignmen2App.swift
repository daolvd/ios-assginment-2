//
//  Assignmen2App.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import SwiftUI

@main
struct Assignmen2App: App {

    /// `ScoreStorageService` lives at the app level and is injected into the
    /// environment so every screen — `HighScoreView`, `GameView`, `GameOverView` —
    /// observes the same reactive instance without prop-drilling.
    @StateObject private var scoreService = ScoreStorageService()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(scoreService)
        }
    }
}
