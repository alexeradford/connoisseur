//
//  RankedEntryTimePlaceStepView.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import SwiftUI

struct RankedEntryTimePlaceStepView: View {
    let list: RankedList
    @Binding var draft: RankedEntryDraft
    let onPickPlace: () -> Void
    let onClearPlace: () -> Void

    private var tint: Color {
        ConnoisseurTheme.tint(named: list.tintName)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            RankedEntryScreenHeader(title: "When and where?")

            DatePicker("Date", selection: $draft.rankedAt, displayedComponents: [.date, .hourAndMinute])
                .font(.headline)
                .datePickerStyle(.compact)
                .padding(16)
                .connoisseurField(cornerRadius: 22)

            VStack(spacing: 10) {
                Button(action: onPickPlace) {
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(draft.trimmedLocationName.isEmpty ? "Place" : draft.trimmedLocationName)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(draft.trimmedLocationAddress.isEmpty ? "Pick a location" : draft.trimmedLocationAddress)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Text("Change")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(tint)
                    }
                    .padding(16)
                    .connoisseurField(cornerRadius: 22)
                }
                .buttonStyle(.plain)

                if draft.selectedRankedLocation != nil {
                    Button("Clear Place", action: onClearPlace)
                        .font(.subheadline.weight(.semibold))
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 122)
    }
}
