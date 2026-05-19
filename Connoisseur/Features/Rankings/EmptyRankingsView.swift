//
//  EmptyRankingsView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct EmptyRankingsView: View {
    let category: RankingCategory
    let addItem: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "camera.macro")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(ConnoisseurTheme.tint(named: category.tintName))
                .symbolEffect(.pulse)

            Text("Add the first contender")
                .font(.title.bold())

            Button(action: addItem) {
                Label("Add", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(ConnoisseurTheme.tint(named: category.tintName))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 52)
        .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 8))
    }
}
