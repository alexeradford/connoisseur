//
//  TabSheetContext.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import Foundation

struct TabSheetContext {
    let selectedDetent: TabSheetDetent
    let height: CGFloat
    let expansionProgress: CGFloat
    let bottomSafeArea: CGFloat
    let isAtSmallestDetent: Bool
    let isAtLargestDetent: Bool

    var isExpanded: Bool {
        !isAtSmallestDetent
    }
}
