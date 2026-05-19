//
//  MetricPolarity.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation

enum MetricPolarity: String, CaseIterable, Identifiable, Codable {
    case positive
    case neutral
    case negative

    var id: String { rawValue }

    var title: String {
        switch self {
        case .positive:
            "Helps"
        case .neutral:
            "Context"
        case .negative:
            "Hurts"
        }
    }

    var symbolName: String {
        switch self {
        case .positive:
            "arrow.up.right.circle.fill"
        case .neutral:
            "equal.circle.fill"
        case .negative:
            "arrow.down.right.circle.fill"
        }
    }
}
