//
//  RankedListPickerDismissButton.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankedListPickerDismissButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "square.grid.2x2.fill")
                .font(.headline.weight(.bold))
                .frame(width: 42, height: 42)
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Show lists")
    }
}
