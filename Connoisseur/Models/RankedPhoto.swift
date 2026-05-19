//
//  RankedPhoto.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

@Model
final class RankedPhoto {
    var id: UUID

    @Attribute(.externalStorage)
    var data: Data

    var createdAt: Date
    var item: RankedItem?

    init(id: UUID = UUID(), data: Data, createdAt: Date = .now, item: RankedItem? = nil) {
        self.id = id
        self.data = data
        self.createdAt = createdAt
        self.item = item
    }
}
