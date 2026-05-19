//
//  RankedItemCard.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankedItemCard: View {
    let category: RankingCategory
    let item: RankedItem
    let rank: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                if let photo = item.sortedPhotos.first {
                    PhotoThumbnail(data: photo.data)
                } else {
                    Rectangle()
                        .fill(ConnoisseurTheme.tint(named: category.tintName).opacity(0.14))
                        .overlay {
                            Image(systemName: "photo.badge.plus")
                                .font(.title2)
                                .foregroundStyle(ConnoisseurTheme.tint(named: category.tintName))
                        }
                }
            }
            .frame(width: 76, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("#\(rank)")
                        .font(.headline.monospacedDigit().weight(.bold))
                        .foregroundStyle(ConnoisseurTheme.tint(named: category.tintName))

                    Text(item.title)
                        .font(.headline)
                        .lineLimit(2)

                    Spacer()
                }

                if !item.locationName.isEmpty {
                    Label(item.locationName, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Label(item.displayDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                MetricSparklineView(category: category, item: item)
            }

            Text(item.score(using: category.sortedMetrics).scoreString)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(12)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        }
    }
}
