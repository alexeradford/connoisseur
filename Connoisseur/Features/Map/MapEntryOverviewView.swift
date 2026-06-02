//
//  MapEntryOverviewView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import SwiftUI

struct MapEntryOverviewView: View {
    let item: MapEntryItem
    let context: TabSheetContext
    let dismiss: () -> Void

    private var entry: RankedEntry { item.entry }
    private var list: RankedList { item.list }
    private var tint: Color { ConnoisseurTheme.tint(named: list.tintName) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    scorePanel
                    details

                    if !entry.notes.isEmpty {
                        notes
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, max(context.bottomSafeArea, 10) + 12)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("#\(item.rank)")
                .font(.headline.monospacedDigit().bold())
                .foregroundStyle(tint)
                .frame(minWidth: 42, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(list.title)
                    .font(.caption.bold())
                    .foregroundStyle(tint)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(.quaternary, in: Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close overview")
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    private var scorePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(entry.score(using: list.sortedMetrics).scoreString)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text("/10")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            ForEach(list.sortedMetrics) { metric in
                let value = entry.rating(for: metric)?.value ?? metric.minimumValue

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label(metric.title, systemImage: metric.polarity.symbolName)
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text(value.scoreString)
                            .font(.subheadline.monospacedDigit().weight(.bold))
                    }

                    ProgressView(value: metric.normalizedValue(for: value))
                        .tint(metric.polarity == .negative ? .red : tint)
                }
            }
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !entry.locationName.isEmpty {
                Label(entry.locationName, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if entry.coordinate == nil {
                Label("No location", systemImage: "mappin.slash")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Label(entry.displayDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var notes: some View {
        Text(entry.notes)
            .font(.body)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
