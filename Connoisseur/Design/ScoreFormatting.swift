//
//  ScoreFormatting.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation

extension Double {
    var scoreString: String {
        formatted(.number.precision(.fractionLength(1)))
    }

    var compactWeightString: String {
        formatted(.number.precision(.fractionLength(0...1)))
    }
}
