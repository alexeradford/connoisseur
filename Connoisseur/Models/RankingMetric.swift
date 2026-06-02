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
    var id: UUID = UUID()
    var title: String = ""
    var weight: Double = 1
    var minimumValue: Double = 0
    var maximumValue: Double = 10
    var polarityRawValue: String = MetricPolarity.positive.rawValue
    var sortIndex: Int = 0
    var createdAt: Date = Date()
    var list: RankedList?

    init(
        id: UUID = UUID(),
        title: String,
        weight: Double = 1,
        minimumValue: Double = 0,
        maximumValue: Double = 10,
        polarity: MetricPolarity = .positive,
        sortIndex: Int = 0,
        createdAt: Date = .now,
        list: RankedList? = nil
    ) {
        self.id = id
        self.title = title
        self.weight = weight
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.polarityRawValue = polarity.rawValue
        self.sortIndex = sortIndex
        self.createdAt = createdAt
        self.list = list
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
