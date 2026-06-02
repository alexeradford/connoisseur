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
    var id: UUID = UUID()

    @Attribute(.externalStorage)
    var data: Data = Data()

    var createdAt: Date = Date()
    var entry: RankedEntry?

    init(id: UUID = UUID(), data: Data, createdAt: Date = .now, entry: RankedEntry? = nil) {
        self.id = id
        self.data = data
        self.createdAt = createdAt
        self.entry = entry
    }
}
