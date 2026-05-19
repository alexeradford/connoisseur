//
//  RankingCategory.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

@Model
final class RankingCategory {
    var id: UUID
    var title: String
    var prompt: String
    var symbolName: String
    var tintName: String
    var generatedIconFilename: String?
    var sortIndex: Int?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \RankingMetric.category)
    var metrics: [RankingMetric]

    @Relationship(deleteRule: .cascade, inverse: \RankedItem.category)
    var items: [RankedItem]

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
        items: [RankedItem] = []
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
        self.items = items
    }

    var sortedMetrics: [RankingMetric] {
        metrics.sorted {
            if $0.sortIndex == $1.sortIndex {
                return $0.createdAt < $1.createdAt
            }

            return $0.sortIndex < $1.sortIndex
        }
    }

    var rankedItems: [RankedItem] {
        items.sorted {
            let left = $0.score(using: sortedMetrics)
            let right = $1.score(using: sortedMetrics)

            if left == right {
                return $0.updatedAt > $1.updatedAt
            }

            return left > right
        }
    }

    var scoredItems: [RankedItem] {
        rankedItems.filter { !$0.ratings.isEmpty }
    }

    static func ordered(_ categories: [RankingCategory]) -> [RankingCategory] {
        categories.sorted {
            guard let leftSortIndex = $0.sortIndex, let rightSortIndex = $1.sortIndex else {
                return $0.createdAt < $1.createdAt
            }

            if leftSortIndex == rightSortIndex {
                return $0.createdAt < $1.createdAt
            }

            return leftSortIndex < rightSortIndex
        }
    }
}
