//
//  EmptyRankedListView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct EmptyRankedListView: View {
    let list: RankedList
    let addEntry: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "camera.macro")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
                .symbolEffect(.pulse)

            Text("Add the first contender")
                .font(.title.bold())

            Button(action: addEntry) {
                Label("Add", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(ConnoisseurTheme.tint(named: list.tintName))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 52)
    }
}
