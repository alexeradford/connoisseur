//
//  MapEntryRow.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import SwiftUI

struct MapEntryRow: View {
    let item: MapEntryItem
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text("#\(item.rank)")
                .font(.headline.monospacedDigit().bold())
                .foregroundStyle(ConnoisseurTheme.tint(named: item.list.tintName))
                .frame(width: 42, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(item.list.title)
                        .font(.caption.bold())
                        .foregroundStyle(ConnoisseurTheme.tint(named: item.list.tintName))
                    
                    if !item.entry.locationName.isEmpty {
                        Text(item.entry.locationName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else if item.entry.coordinate == nil {
                        Text("No location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            Text(item.entry.score(using: item.list.sortedMetrics).scoreString)
                .font(.headline.monospacedDigit().bold())
                .foregroundStyle(isSelected ? ConnoisseurTheme.tint(named: item.list.tintName) : .primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
