//
//  BubbleType.swift
//  Assignmen2
//
//  Created by Van Dao Le on 13/4/2026.
//

import Foundation
import SwiftUI

enum BubbleType: CaseIterable, Codable {
    case red
    case pink
    case green
    case blue
    case black
    
    var points: Int {
        switch self {
        case .red: return 1
        case .pink: return 2
        case .green: return 5
        case .blue: return 8
        case .black: return 10
        }
    }
    
    var probability: Int {
        switch self {
        case .red: return 40
        case .pink: return 30
        case .green: return 15
        case .blue: return 10
        case .black: return 5
        }
    }
    
    var color: Color {
        switch self {
        case .red: return .red
        case .pink: return .pink
        case .green: return .green
        case .blue: return .blue
        case .black: return .black
        }
    }
}
