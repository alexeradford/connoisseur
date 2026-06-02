//
//  TabSheetMetrics.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import Foundation

struct TabSheetMetrics {
    let resolvedDetents: [(detent: TabSheetDetent, height: CGFloat)]
    let currentDetentHeight: CGFloat
    let height: CGFloat
    let contentWidth: CGFloat
    let horizontalMargin: CGFloat
    let bottomMargin: CGFloat
    let opaqueBackgroundOpacity: CGFloat
    let context: TabSheetContext
}
