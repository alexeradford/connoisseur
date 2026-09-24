//
//  RankedEntryEditorStep.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import Foundation

enum RankedEntryEditorStep: Hashable, Identifiable {
    case identity
    case timePlace
    case rating(UUID)
    case notes
    case summary

    var id: String {
        switch self {
        case .identity:
            "identity"
        case .timePlace:
            "time-place"
        case .rating(let metricID):
            "rating-\(metricID.uuidString)"
        case .notes:
            "notes"
        case .summary:
            "summary"
        }
    }
}
