//
//  MenuButtonView.swift
//  Assignmen2
//
//  Created by Van Dao Le on 15/4/2026.
//

import SwiftUI

/// Standard styled button utilized for main menu navigation elements.
struct MenuButtonView: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(color)
            .cornerRadius(16)
            .padding(.horizontal, 24)
    }
}

#Preview {
    MenuButtonView(title: "New Game", color: .green)
}
