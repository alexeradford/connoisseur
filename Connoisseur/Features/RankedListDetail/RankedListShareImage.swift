//
//  RankedListShareImage.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-01.
//

import CoreTransferable
import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#endif

struct RankedListShareImage: Transferable, Sendable {
    private static let renderWidth: CGFloat = 393
    private static let renderScale: CGFloat = 3

    let list: RankedListShareSnapshot
    let entries: [RankedEntryShareSnapshot]
    let colorScheme: ColorScheme

    @MainActor
    init(list: RankedList, entries: [RankedEntry], colorScheme: ColorScheme) {
        self.list = RankedListShareSnapshot(list: list)
        self.entries = entries.map { RankedEntryShareSnapshot(entry: $0, metrics: list.sortedMetrics) }
        self.colorScheme = colorScheme
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { image in
            try await image.pngData()
        }
    }

    @MainActor
    private func pngData() throws -> Data {
#if canImport(UIKit)
        let renderer = ImageRenderer(
            content: RankedListShareImageView(image: self)
                .environment(\.colorScheme, colorScheme)
        )
        renderer.proposedSize = ProposedViewSize(width: Self.renderWidth, height: nil)
        renderer.scale = Self.renderScale
        renderer.isOpaque = true

        guard let data = renderer.uiImage?.pngData() else {
            throw RankedListShareImageError.renderFailed
        }

        return data
#else
        throw RankedListShareImageError.renderFailed
#endif
    }
}

private enum RankedListShareImageError: Error {
    case renderFailed
}

struct RankedListShareSnapshot: Sendable {
    let id: UUID
    let title: String
    let prompt: String
    let symbolName: String
    let tintName: String
    let entryCount: Int
    let metricCount: Int
    let metrics: [RankingMetricShareSnapshot]

    @MainActor
    init(list: RankedList) {
        id = list.id
        title = list.title
        prompt = list.prompt
        symbolName = list.symbolName
        tintName = list.tintName
        entryCount = list.entryCount
        metricCount = list.metricCount
        metrics = list.sortedMetrics.map(RankingMetricShareSnapshot.init)
    }
}

struct RankingMetricShareSnapshot: Identifiable, Sendable {
    let id: UUID
    let title: String
    let weight: Double
    let minimumValue: Double
    let maximumValue: Double
    let polarity: MetricPolarity

    @MainActor
    init(metric: RankingMetric) {
        id = metric.id
        title = metric.title
        weight = metric.effectiveWeight
        minimumValue = metric.minimumValue
        maximumValue = metric.maximumValue
        polarity = metric.polarity
    }

    func normalizedValue(for rawValue: Double) -> Double {
        guard maximumValue > minimumValue else { return 0 }

        let boundedValue = min(max(rawValue, minimumValue), maximumValue)
        return (boundedValue - minimumValue) / (maximumValue - minimumValue)
    }
}

struct RankedEntryShareSnapshot: Identifiable, Sendable {
    let id: UUID
    let title: String
    let locationName: String
    let displayDate: Date
    let score: Double
    let photoData: Data?
    let metricValues: [UUID: Double]

    @MainActor
    init(entry: RankedEntry, metrics: [RankingMetric]) {
        id = entry.id
        title = entry.title
        locationName = entry.locationName
        displayDate = entry.displayDate
        score = entry.score(using: metrics)
        photoData = entry.sortedPhotos.first?.data
        metricValues = Dictionary(
            uniqueKeysWithValues: entry.availableRatings.map { rating in
                (rating.metricID, rating.value)
            }
        )
    }
}

private struct RankedListShareImageView: View {
    let image: RankedListShareImage

    var body: some View {
        VStack(spacing: 16) {
            RankedListShareCard(list: image.list, entries: image.entries)

            Text("Connoisseur")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(width: 393, alignment: .top)
        .background {
            ConnoisseurTheme.canvas
                .overlay { ConnoisseurTheme.listBackground(tintName: image.list.tintName) }
        }
    }
}

private struct RankedListShareCard: View {
    let list: RankedListShareSnapshot
    let entries: [RankedEntryShareSnapshot]

    var body: some View {
        VStack(spacing: 0) {
            RankedListShareHeader(list: list)

            VStack(spacing: 0) {
                if entries.isEmpty {
                    RankedListShareEmptyState(list: list)
                } else {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        VStack(spacing: 0) {
                            RankedListShareEntryRow(
                                list: list,
                                entry: entry,
                                rank: index + 1
                            )

                            if index < entries.count - 1 {
                                Divider()
                                    .overlay(ConnoisseurTheme.tint(named: list.tintName).opacity(0.14))
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background {
            RankedListSurface(tintName: list.tintName, cornerRadius: 26)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct RankedListShareHeader: View {
    let list: RankedListShareSnapshot

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(ConnoisseurTheme.tint(named: list.tintName).opacity(0.18))

                Image(systemName: list.symbolName)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 5) {
                Text(list.title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                if !list.prompt.isEmpty {
                    Text(list.prompt)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }

                HStack(spacing: 10) {
                    Label("\(list.entryCount)", systemImage: "star.fill")
                    Label("\(list.metricCount)", systemImage: "slider.horizontal.3")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
                .labelStyle(.titleAndIcon)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            LinearGradient(
                colors: [
                    ConnoisseurTheme.headerHighlight,
                    ConnoisseurTheme.tint(named: list.tintName).opacity(0.08),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct RankedListShareEntryRow: View {
    let list: RankedListShareSnapshot
    let entry: RankedEntryShareSnapshot
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if let photoData = entry.photoData {
                    PhotoThumbnail(data: photoData)
                } else {
                    Rectangle()
                        .fill(ConnoisseurTheme.tint(named: list.tintName).opacity(0.14))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
                        }
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("#\(rank)")
                        .font(.headline.monospacedDigit().weight(.bold))
                        .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))

                    Text(entry.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }

                if !entry.locationName.isEmpty {
                    Label(entry.locationName, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Label(entry.displayDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                RankedListShareMetricStrip(
                    tintName: list.tintName,
                    metrics: list.metrics,
                    values: entry.metricValues
                )
            }

            Spacer(minLength: 0)

            Text(entry.score.scoreString)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.vertical, 12)
    }
}

private struct RankedListShareMetricStrip: View {
    let tintName: String
    let metrics: [RankingMetricShareSnapshot]
    let values: [UUID: Double]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(metrics.prefix(8)) { metric in
                Capsule()
                    .fill(ConnoisseurTheme.tint(named: tintName).opacity(metricOpacity(for: metric)))
                    .frame(width: 18, height: 5)
            }
        }
        .frame(height: 8, alignment: .leading)
    }

    private func metricOpacity(for metric: RankingMetricShareSnapshot) -> Double {
        guard let value = values[metric.id] else { return 0.18 }

        let normalizedValue = metric.normalizedValue(for: value)
        let displayValue = switch metric.polarity {
        case .positive:
            normalizedValue
        case .neutral:
            0.5
        case .negative:
            1 - normalizedValue
        }

        return 0.22 + displayValue * 0.58
    }
}

private struct RankedListShareEmptyState: View {
    let list: RankedListShareSnapshot

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: list.symbolName)
                .font(.title2.weight(.bold))
                .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))

            Text("No entries yet")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("This list is ready for its first contender.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}
