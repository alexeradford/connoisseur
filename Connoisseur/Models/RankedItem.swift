//
//  RankedItem.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

@Model
final class RankedItem {
    var id: UUID
    var title: String
    var notes: String
    var locationName: String
    var locationAddress: String
    var latitude: Double?
    var longitude: Double?
    var rankedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var category: RankingCategory?

    @Relationship(deleteRule: .cascade, inverse: \MetricRating.item)
    var ratings: [MetricRating]

    @Relationship(deleteRule: .cascade, inverse: \RankedPhoto.item)
    var photos: [RankedPhoto]

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        locationName: String = "",
        locationAddress: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        rankedAt: Date = .now,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        category: RankingCategory? = nil,
        ratings: [MetricRating] = [],
        photos: [RankedPhoto] = []
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
        self.rankedAt = rankedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
        self.ratings = ratings
        self.photos = photos
    }

    var coordinate: RankingCoordinate? {
        guard let latitude, let longitude else { return nil }
        return RankingCoordinate(latitude: latitude, longitude: longitude)
    }

    var displayDate: Date {
        rankedAt ?? createdAt
    }

    var sortedPhotos: [RankedPhoto] {
        photos.sorted { $0.createdAt < $1.createdAt }
    }

    func rating(for metric: RankingMetric) -> MetricRating? {
        ratings.first { $0.metricID == metric.id }
    }

    func score(using metrics: [RankingMetric]) -> Double {
        let scoringMetrics = metrics.filter { $0.polarity != .neutral && $0.effectiveWeight > 0 }
        let possibleScore = scoringMetrics.reduce(0) { $0 + $1.effectiveWeight }

        guard possibleScore > 0 else { return 0 }

        let earnedScore = scoringMetrics.reduce(0) { partialResult, metric in
            guard let rating = rating(for: metric) else { return partialResult }
            return partialResult + metric.scoreContribution(for: rating.value)
        }

        return earnedScore / possibleScore * 10
    }
}

struct RankingCoordinate: Hashable {
    let latitude: Double
    let longitude: Double
}
