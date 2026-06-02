//
//  ConnoisseurTheme.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension Color {
    /// Builds a color that resolves to a different value in light and dark mode.
    ///
    /// This is the single place the app reconciles its hand-picked palette with the
    /// system appearance, so the rest of the codebase can lean on semantic tokens
    /// instead of hardcoding `Color.white` and fighting the framework.
    init(light: @autoclosure @escaping () -> Color, dark: @autoclosure @escaping () -> Color) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traitCollection in
            UIColor(traitCollection.userInterfaceStyle == .dark ? dark() : light())
        })
        #else
        self = light()
        #endif
    }
}

enum ConnoisseurTheme {
    // MARK: - Canvas & surfaces

    /// The opaque base color that sits behind every screen.
    static let canvas = Color(
        light: Color(red: 0.97, green: 0.96, blue: 0.93),
        dark: Color(red: 0.07, green: 0.07, blue: 0.09)
    )

    /// Gradient stops for the floating list/preview cards (`RankedListSurface`).
    static let cardSurfaceColors: [Color] = [
        Color(light: .white.opacity(0.98), dark: Color(red: 0.17, green: 0.17, blue: 0.20)),
        Color(light: .white.opacity(0.94), dark: Color(red: 0.13, green: 0.13, blue: 0.16)),
    ]

    /// Hairline rim around the floating cards — a bright highlight in light mode,
    /// a subtle light rim in dark mode.
    static let cardStroke = Color(
        light: .white.opacity(0.82),
        dark: .white.opacity(0.10)
    )

    /// Top highlight for the card header overlay.
    static let headerHighlight = Color(
        light: .white.opacity(0.7),
        dark: .white.opacity(0.05)
    )

    // MARK: - Screen backgrounds

    static let background = LinearGradient(
        colors: [
            Color(light: Color(red: 0.98, green: 0.96, blue: 0.91), dark: Color(red: 0.10, green: 0.10, blue: 0.12)),
            Color(light: Color(red: 0.92, green: 0.98, blue: 0.97), dark: Color(red: 0.08, green: 0.09, blue: 0.11)),
            Color(light: Color(red: 0.97, green: 0.94, blue: 0.99), dark: Color(red: 0.09, green: 0.08, blue: 0.12)),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let onboardingBackground = LinearGradient(
        colors: [
            Color(light: Color(red: 0.82, green: 0.90, blue: 0.99), dark: Color(red: 0.10, green: 0.12, blue: 0.18)),
            Color(light: Color(red: 0.93, green: 0.97, blue: 1.00), dark: Color(red: 0.07, green: 0.08, blue: 0.12)),
            Color(light: .white, dark: Color(red: 0.06, green: 0.06, blue: 0.08)),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Tinted backdrop for a single list, fading from the list's tint into the canvas.
    static func listBackground(tintName: String) -> LinearGradient {
        tintedBackground(tints: [tint(named: tintName)])
    }

    /// Tinted backdrop for the aggregate views (map / all entries).
    static let allListsBackground = tintedBackground(
        tints: [tint(named: "gold"), tint(named: "coral")]
    )

    private static func tintedBackground(tints: [Color]) -> LinearGradient {
        let top = tints.first ?? tint(named: "mint")
        let mid = tints.count > 1 ? tints[1] : top
        return LinearGradient(
            colors: [
                top.opacity(0.32),
                mid.opacity(0.14),
                canvas,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Tints

    static func tint(named name: String) -> Color {
        switch name {
        // Greens
        case "emerald":
            adaptiveTint(0.13, 0.62, 0.42)
        case "forest":
            adaptiveTint(0.16, 0.43, 0.24)
        case "olive":
            adaptiveTint(0.45, 0.50, 0.18)
        // Teals & blues
        case "teal":
            adaptiveTint(0.08, 0.52, 0.62)
        case "aqua":
            adaptiveTint(0.10, 0.66, 0.70)
        case "sky":
            adaptiveTint(0.20, 0.60, 0.92)
        case "blue":
            adaptiveTint(0.17, 0.43, 0.86)
        case "indigo":
            adaptiveTint(0.27, 0.32, 0.74)
        // Purples & pinks
        case "violet":
            adaptiveTint(0.48, 0.32, 0.86)
        case "plum":
            adaptiveTint(0.55, 0.27, 0.60)
        case "magenta":
            adaptiveTint(0.80, 0.18, 0.66)
        case "rose":
            adaptiveTint(0.87, 0.24, 0.50)
        case "berry":
            adaptiveTint(0.78, 0.20, 0.42)
        // Reds & oranges
        case "crimson":
            adaptiveTint(0.83, 0.16, 0.24)
        case "coral":
            adaptiveTint(0.93, 0.34, 0.26)
        case "tangerine":
            adaptiveTint(0.96, 0.45, 0.13)
        case "citrus":
            adaptiveTint(0.95, 0.58, 0.16)
        // Yellows
        case "gold":
            adaptiveTint(0.82, 0.58, 0.12)
        case "amber":
            adaptiveTint(0.90, 0.70, 0.10)
        // Neutrals
        case "slate":
            adaptiveTint(0.34, 0.39, 0.48)
        case "graphite":
            adaptiveTint(0.30, 0.32, 0.35)
        // mint (default)
        default:
            adaptiveTint(0.05, 0.58, 0.48)
        }
    }

    /// Wraps a base brand color so it lifts toward white in dark mode, keeping the
    /// deeper tints legible as accents on dark surfaces while preserving their hue.
    private static func adaptiveTint(_ red: Double, _ green: Double, _ blue: Double) -> Color {
        let lift = 0.22
        return Color(
            light: Color(red: red, green: green, blue: blue),
            dark: Color(
                red: red + (1 - red) * lift,
                green: green + (1 - green) * lift,
                blue: blue + (1 - blue) * lift
            )
        )
    }

    static let tintNames = RankedListAppearanceOptions.tints.map(\.name)

    static func tintTitle(named name: String) -> String {
        RankedListAppearanceOptions.tints.first { $0.name == name }?.title ?? name.capitalized
    }
}

extension View {
    /// Frosted, dark-mode-adaptive background for input fields and inline panels.
    ///
    /// Replaces the old hand-tuned `.white.opacity(...)` surfaces, which only looked
    /// right over the light gradient. A material picks up whatever is behind it and
    /// adapts to the system appearance automatically.
    func connoisseurField(cornerRadius: CGFloat = 8) -> some View {
        background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
