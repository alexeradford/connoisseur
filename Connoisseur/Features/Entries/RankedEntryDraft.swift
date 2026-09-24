//
//  RankedEntryDraft.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import Foundation

struct RankedEntryDraft: Equatable {
    var title: String
    var notes: String
    var ratings: [UUID: Double]
    var locationName: String
    var locationAddress: String
    var latitude: Double?
    var longitude: Double?
    var rankedAt: Date
    var pendingPhotoData: [Data]
    let existingPhotoData: Data?

    init(list: RankedList, entry: RankedEntry?) {
        title = entry?.title ?? ""
        notes = entry?.notes ?? ""
        ratings = Dictionary(uniqueKeysWithValues: list.sortedMetrics.map { metric in
            (metric.id, entry?.rating(for: metric)?.value ?? Self.defaultRating(for: metric))
        })
        locationName = entry?.locationName ?? ""
        locationAddress = entry?.locationAddress ?? ""
        latitude = entry?.latitude
        longitude = entry?.longitude
        rankedAt = entry?.displayDate ?? .now
        pendingPhotoData = []
        existingPhotoData = entry?.sortedPhotos.first?.data
    }

    var displayPhotoData: Data? {
        pendingPhotoData.first ?? existingPhotoData
    }

    var selectedRankedLocation: RankedLocation? {
        guard let latitude, let longitude, !trimmedLocationName.isEmpty else { return nil }

        return RankedLocation(
            name: trimmedLocationName,
            address: trimmedLocationAddress,
            latitude: latitude,
            longitude: longitude
        )
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedLocationName: String {
        locationName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedLocationAddress: String {
        locationAddress.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func defaultRating(for metric: RankingMetric) -> Double {
        min(max(7, metric.minimumValue), metric.maximumValue)
    }

    func projectedScore(using metrics: [RankingMetric]) -> Double {
        let scoringMetrics = metrics.filter { $0.polarity != .neutral && $0.effectiveWeight > 0 }
        let possibleScore = scoringMetrics.reduce(0) { $0 + $1.effectiveWeight }
        guard possibleScore > 0 else { return 0 }

        let earnedScore = scoringMetrics.reduce(0) { partialResult, metric in
            partialResult + metric.scoreContribution(for: ratings[metric.id] ?? Self.defaultRating(for: metric))
        }

        return earnedScore / possibleScore * 10
    }

    mutating func applyLocation(_ location: RankedLocation?) {
        locationName = location?.name ?? ""
        locationAddress = location?.address ?? ""
        latitude = location?.latitude
        longitude = location?.longitude
    }
}
