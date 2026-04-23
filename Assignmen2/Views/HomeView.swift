//
//  HomeView.swift
//  Assignmen2
//
//  Created by Van Dao Le on 14/4/2026.
//

import SwiftUI

/// Landing page for the application, providing navigation to the Settings and High Score screens.
struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // App logo – scales to available width so it renders correctly
                // on all device sizes and orientations.
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 200)
                    .padding(.horizontal, 24)

                VStack(spacing: 20) {
                    NavigationLink(destination: SettingsView()) {
                        MenuButtonView(title: "New Game", color: .green)
                    }

                    NavigationLink(destination: HighScoreView()) {
                        MenuButtonView(title: "High Scores", color: .orange)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .background(Color(.systemGray6))
        }
    }
}

#Preview {
    HomeView()
}
