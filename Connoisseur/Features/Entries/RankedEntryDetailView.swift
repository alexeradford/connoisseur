//
//  RankedEntryDetailView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

struct RankedEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let list: RankedList
    let entry: RankedEntry
    @State private var isEditing = false
    @State private var isConfirmingDeletion = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                scorePanel

                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.body)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .connoisseurField()
                }

                Label(entry.displayDate.formatted(date: .complete, time: .shortened), systemImage: "calendar")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .connoisseurField()

                if entry.coordinate != nil {
                    RankingSingleEntryMapView(entry: entry)
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        .background(ConnoisseurTheme.background.ignoresSafeArea())
        .navigationTitle(entry.title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(role: .destructive) {
                    isConfirmingDeletion = true
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
                .accessibilityLabel("Delete entry")
                .confirmationDialog(
                    "Delete Entry?",
                    isPresented: $isConfirmingDeletion,
                    titleVisibility: .visible
                ) {
                    Button("Delete Entry", role: .destructive) {
                        deleteEntry()
                    }
                } message: {
                    Text("Delete \"\(entry.title)\" from \(list.title)?")
                }

                Button {
                    isEditing = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("Edit entry")
            }
        }
        .sheet(isPresented: $isEditing) {
            RankedEntryEditorView(list: list, entry: entry)
        }
    }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            if let photo = entry.sortedPhotos.first {
                PhotoThumbnail(data: photo.data)
                    .frame(height: 300)
            } else {
                Rectangle()
                    .fill(ConnoisseurTheme.tint(named: list.tintName).opacity(0.18))
                    .frame(height: 220)
                    .overlay {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 54, weight: .bold))
                            .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(entry.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 8)

                if !entry.locationName.isEmpty {
                    Label(entry.locationName, systemImage: "mappin.and.ellipse")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 8)
                }

                Label(entry.displayDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
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
                Text(entry.score(using: list.sortedMetrics).scoreString)
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text("/10")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)

                Spacer()
            }

            ForEach(list.sortedMetrics) { metric in
                let value = entry.rating(for: metric)?.value ?? metric.minimumValue

                MetricScoreRow(
                    metric: metric,
                    value: value,
                    tint: ConnoisseurTheme.tint(named: list.tintName)
                )
            }
        }
        .padding(18)
        .connoisseurField()
    }

    private func deleteEntry() {
        list.removeEntry(entry)
        list.updatedAt = .now
        modelContext.delete(entry)
        dismiss()
    }
}
