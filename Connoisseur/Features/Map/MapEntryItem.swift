//
//  MapEntryItem.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import Foundation

struct MapEntryItem: Identifiable {
    let list: RankedList
    let entry: RankedEntry
    let rank: Int
    
    var id: UUID {
        entry.id
    }
}
