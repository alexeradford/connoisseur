//
//  RankedListIconView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankedListIconView: View {
    enum Style {
        case badge
        case glyph
    }

    let symbolName: String
    let tintName: String
    let generatedIconFilename: String?
    let size: CGFloat
    let cornerRadius: CGFloat
    let style: Style
    let symbolFont: Font

    init(
        symbolName: String,
        tintName: String,
        generatedIconFilename: String? = nil,
        size: CGFloat,
        cornerRadius: CGFloat = 8,
        style: Style = .badge,
        symbolFont: Font? = nil
    ) {
        self.symbolName = symbolName
        self.tintName = tintName
        self.generatedIconFilename = generatedIconFilename
        self.size = size
        self.cornerRadius = cornerRadius
        self.style = style
        self.symbolFont = symbolFont ?? .system(size: size * 0.44, weight: .semibold)
    }

    init(
        list: RankedList,
        size: CGFloat,
        cornerRadius: CGFloat = 8,
        style: Style = .badge,
        symbolFont: Font? = nil
    ) {
        self.init(
            symbolName: list.symbolName,
            tintName: list.tintName,
            generatedIconFilename: list.generatedIconFilename,
            size: size,
            cornerRadius: cornerRadius,
            style: style,
            symbolFont: symbolFont
        )
    }

    var body: some View {
        if let generatedIcon = RankedListIconStorage.image(for: generatedIconFilename) {
            generatedIcon
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            symbolIcon
        }
    }

    @ViewBuilder
    private var symbolIcon: some View {
        switch style {
        case .badge:
            Image(systemName: symbolName)
                .font(symbolFont)
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(ConnoisseurTheme.tint(named: tintName).gradient, in: Circle())
        case .glyph:
            Image(systemName: symbolName)
                .font(symbolFont)
                .frame(width: size, height: size)
        }
    }
}
