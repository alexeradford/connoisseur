//
//  RankingMetric.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

@Model
final class RankingMetric {
    var id: UUID
    var title: String
    var weight: Double
    var minimumValue: Double
    var maximumValue: Double
    var polarityRawValue: String
    var sortIndex: Int
    var createdAt: Date
    var category: RankingCategory?

    init(
        id: UUID = UUID(),
        title: String,
        weight: Double = 1,
        minimumValue: Double = 0,
        maximumValue: Double = 10,
        polarity: MetricPolarity = .positive,
        sortIndex: Int = 0,
        createdAt: Date = .now,
        category: RankingCategory? = nil
    ) {
        self.id = id
        self.title = title
        self.weight = weight
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.polarityRawValue = polarity.rawValue
        self.sortIndex = sortIndex
        self.createdAt = createdAt
        self.category = category
    }

    var polarity: MetricPolarity {
        get { MetricPolarity(rawValue: polarityRawValue) ?? .positive }
        set { polarityRawValue = newValue.rawValue }
    }

    var effectiveWeight: Double {
        max(0, weight)
    }

    func normalizedValue(for rawValue: Double) -> Double {
        guard maximumValue > minimumValue else { return 0 }

        let boundedValue = min(max(rawValue, minimumValue), maximumValue)
        return (boundedValue - minimumValue) / (maximumValue - minimumValue)
    }

    func scoreContribution(for rawValue: Double) -> Double {
        let normalizedValue = normalizedValue(for: rawValue)

        switch polarity {
        case .positive:
            return normalizedValue * effectiveWeight
        case .neutral:
            return 0
        case .negative:
            return (1 - normalizedValue) * effectiveWeight
        }
    }
}
