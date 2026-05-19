//
//  RankedItemDetailView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankedItemDetailView: View {
    let category: RankingCategory
    let item: RankedItem
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                scorePanel

                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.body)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 8))
                }

                Label(item.displayDate.formatted(date: .complete, time: .shortened), systemImage: "calendar")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 8))

                if item.coordinate != nil {
                    RankingSingleItemMapView(item: item)
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        .background(ConnoisseurTheme.background.ignoresSafeArea())
        .navigationTitle(item.title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            Button {
                isEditing = true
            } label: {
                Image(systemName: "pencil")
            }
            .accessibilityLabel("Edit item")
        }
        .sheet(isPresented: $isEditing) {
            ItemEditorView(category: category, item: item)
        }
    }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            if let photo = item.sortedPhotos.first {
                PhotoThumbnail(data: photo.data)
                    .frame(height: 300)
            } else {
                Rectangle()
                    .fill(ConnoisseurTheme.tint(named: category.tintName).opacity(0.18))
                    .frame(height: 220)
                    .overlay {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 54, weight: .bold))
                            .foregroundStyle(ConnoisseurTheme.tint(named: category.tintName))
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(radius: 8)

                if !item.locationName.isEmpty {
                    Label(item.locationName, systemImage: "mappin.and.ellipse")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 8)
                }

                Label(item.displayDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(radius: 8)
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var scorePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.score(using: category.sortedMetrics).scoreString)
                    .font(.system(size: 54, weight: .black, design: .rounded))
                    .monospacedDigit()

                Text("/10")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)

                Spacer()
            }

            ForEach(category.sortedMetrics) { metric in
                let value = item.rating(for: metric)?.value ?? metric.minimumValue

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label(metric.title, systemImage: metric.polarity.symbolName)
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text(value.scoreString)
                            .font(.subheadline.monospacedDigit().weight(.bold))
                    }

                    ProgressView(value: metric.normalizedValue(for: value))
                        .tint(metric.polarity == .negative ? .red : ConnoisseurTheme.tint(named: category.tintName))
                }
            }
        }
        .padding(18)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
    }
}
