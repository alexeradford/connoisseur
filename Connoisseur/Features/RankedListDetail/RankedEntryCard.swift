//
//  RankedEntryCard.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankedEntryCard: View {
    let list: RankedList
    let entry: RankedEntry
    let rank: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                if let photo = entry.sortedPhotos.first {
                    PhotoThumbnail(data: photo.data)
                } else {
                    Rectangle()
                        .fill(ConnoisseurTheme.tint(named: list.tintName).opacity(0.14))
                        .overlay {
                            Image(systemName: "photo.badge.plus")
                                .font(.title2)
                                .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
                        }
                }
            }
            .frame(width: 76, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("#\(rank)")
                        .font(.headline.monospacedDigit().weight(.bold))
                        .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))

                    Text(entry.title)
                        .font(.headline)
                        .lineLimit(2)

                    Spacer()
                }

                if !entry.locationName.isEmpty {
                    Label(entry.locationName, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Label(entry.displayDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                MetricSparklineView(list: list, entry: entry)
            }

            Text(entry.score(using: list.sortedMetrics).scoreString)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.vertical, 12)
    }
}
