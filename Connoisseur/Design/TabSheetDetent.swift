//
//  TabSheetDetent.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import Foundation

enum TabSheetDetent: Hashable {
    case height(CGFloat)
    case fraction(CGFloat)
    case medium
    case large
    
    func resolvedHeight(in availableHeight: CGFloat) -> CGFloat {
        let proposedHeight = switch self {
        case .height(let height):
            height
        case .fraction(let fraction):
            availableHeight * fraction
        case .medium:
            availableHeight * 0.5
        case .large:
            availableHeight
        }
        
        return min(max(proposedHeight, 0), availableHeight)
    }
}
