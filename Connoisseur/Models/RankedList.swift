//
//  RankedList.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

@Model
final class RankedList {
    var id: UUID = UUID()
    var title: String = ""
    var prompt: String = ""
    var symbolName: String = "trophy.fill"
    var tintName: String = "mint"
    var generatedIconFilename: String?
    var sortIndex: Int?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \RankingMetric.list)
    var metrics: [RankingMetric]?

    @Relationship(deleteRule: .cascade, inverse: \RankedEntry.list)
    var entries: [RankedEntry]?

    init(
        id: UUID = UUID(),
        title: String,
        prompt: String = "",
        symbolName: String = "trophy.fill",
        tintName: String = "mint",
        generatedIconFilename: String? = nil,
        sortIndex: Int? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        metrics: [RankingMetric] = [],
        entries: [RankedEntry] = []
    ) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.symbolName = symbolName
        self.tintName = tintName
        self.generatedIconFilename = generatedIconFilename
        self.sortIndex = sortIndex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.metrics = metrics
        self.entries = entries
    }

    var availableMetrics: [RankingMetric] {
        metrics ?? []
    }

    var availableEntries: [RankedEntry] {
        entries ?? []
    }

    var metricCount: Int {
        availableMetrics.count
    }

    var entryCount: Int {
        availableEntries.count
    }

    var sortedMetrics: [RankingMetric] {
        availableMetrics.sorted {
            if $0.sortIndex == $1.sortIndex {
                return $0.createdAt < $1.createdAt
            }

            return $0.sortIndex < $1.sortIndex
        }
    }

    var rankedEntries: [RankedEntry] {
        availableEntries.sorted {
            let left = $0.score(using: sortedMetrics)
            let right = $1.score(using: sortedMetrics)

            if left == right {
                return $0.updatedAt > $1.updatedAt
            }

            return left > right
        }
    }

    var scoredEntries: [RankedEntry] {
        rankedEntries.filter { !$0.availableRatings.isEmpty }
    }

    func appendMetric(_ metric: RankingMetric) {
        if metrics == nil {
            metrics = []
        }

        metrics?.append(metric)
    }

    func appendEntry(_ entry: RankedEntry) {
        if entries == nil {
            entries = []
        }

        entries?.append(entry)
    }
}
