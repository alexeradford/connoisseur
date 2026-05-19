//
//  ConnoisseurTheme.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

enum ConnoisseurTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.96, blue: 0.91),
            Color(red: 0.92, green: 0.98, blue: 0.97),
            Color(red: 0.97, green: 0.94, blue: 0.99),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func tint(named name: String) -> Color {
        switch name {
        case "berry":
            Color(red: 0.78, green: 0.20, blue: 0.42)
        case "citrus":
            Color(red: 0.95, green: 0.58, blue: 0.16)
        case "violet":
            Color(red: 0.48, green: 0.32, blue: 0.86)
        case "blue":
            Color(red: 0.17, green: 0.43, blue: 0.86)
        default:
            Color(red: 0.05, green: 0.58, blue: 0.48)
        }
    }

    static let tintNames = ["mint", "berry", "citrus", "violet", "blue"]
}
