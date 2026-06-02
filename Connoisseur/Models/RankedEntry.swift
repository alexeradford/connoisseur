//
//  RankedEntry.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

@Model
final class RankedEntry {
    var id: UUID = UUID()
    var title: String = ""
    var notes: String = ""
    var locationName: String = ""
    var locationAddress: String = ""
    var latitude: Double?
    var longitude: Double?
    var rankedAt: Date?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var list: RankedList?

    @Relationship(deleteRule: .cascade, inverse: \MetricRating.entry)
    var ratings: [MetricRating]?

    @Relationship(deleteRule: .cascade, inverse: \RankedPhoto.entry)
    var photos: [RankedPhoto]?

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
        list: RankedList? = nil,
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
        self.list = list
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

    var availableRatings: [MetricRating] {
        ratings ?? []
    }

    var availablePhotos: [RankedPhoto] {
        photos ?? []
    }

    var sortedPhotos: [RankedPhoto] {
        availablePhotos.sorted { $0.createdAt < $1.createdAt }
    }

    func rating(for metric: RankingMetric) -> MetricRating? {
        availableRatings.first { $0.metricID == metric.id }
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

    func appendRating(_ rating: MetricRating) {
        if ratings == nil {
            ratings = []
        }

        ratings?.append(rating)
    }

    func appendPhoto(_ photo: RankedPhoto) {
        if photos == nil {
            photos = []
        }

        photos?.append(photo)
    }
}

struct RankingCoordinate: Hashable {
    let latitude: Double
    let longitude: Double
}
