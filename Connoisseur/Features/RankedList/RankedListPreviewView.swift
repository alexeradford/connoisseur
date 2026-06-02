//
//  RankedListPreviewView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankedListPreviewView: View {
    let list: RankedList

    var body: some View {
        VStack(spacing: 0) {
            RankedListHeaderView(list: list, style: .preview)

            VStack(alignment: .leading, spacing: 9) {
                if list.rankedEntries.isEmpty {
                    emptyPreview
                } else {
                    ForEach(Array(list.rankedEntries.prefix(3).enumerated()), id: \.element.id) { index, entry in
                        previewRow(rank: index + 1, title: entry.title)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(minHeight: 112, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background {
            RankedListSurface(tintName: list.tintName, cornerRadius: 26)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(list.title), \(list.entryCount) entries")
    }

    private var emptyPreview: some View {
        Text("No entries yet")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func previewRow(rank: Int, title: String) -> some View {
        HStack(spacing: 8) {
            Text("#\(rank)")
                .font(.caption2.monospacedDigit().weight(.bold))
                .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
                .frame(width: 24, alignment: .leading)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
