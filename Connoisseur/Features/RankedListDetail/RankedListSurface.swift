//
//  RankedListSurface.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankedListContainer<Header: View, Content: View>: View {
    let tintName: String
    let header: Header
    let content: Content

    init(
        tintName: String,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.tintName = tintName
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background {
            RankedListSurface(tintName: tintName, cornerRadius: 26)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

struct RankedListSurface: View {
    let tintName: String
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(surfaceFill)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(ConnoisseurTheme.cardStroke, lineWidth: 1)
            }
            .shadow(color: ConnoisseurTheme.tint(named: tintName).opacity(0.14), radius: 28, x: 0, y: 18)
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }

    private var surfaceFill: LinearGradient {
        LinearGradient(
            colors: ConnoisseurTheme.cardSurfaceColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct RankedListHeaderView: View {
    enum Style {
        case full
        case preview
    }

    let list: RankedList
    let style: Style

    var body: some View {
        HStack(spacing: iconSpacing) {
            RankedListIconView(
                list: list,
                size: iconSize,
                symbolFont: .system(size: symbolSize, weight: .bold)
            )
            .symbolEffect(.bounce, value: list.id)

            VStack(alignment: .leading, spacing: textSpacing) {
                Text(list.title)
                    .font(titleFont)
                    .foregroundStyle(.primary)
                    .lineLimit(style == .full ? 2 : 1)
                    .minimumScaleFactor(0.72)

                if !list.prompt.isEmpty {
                    Text(list.prompt)
                        .font(promptFont)
                        .foregroundStyle(.secondary)
                        .lineLimit(style == .full ? 2 : 1)
                        .minimumScaleFactor(0.82)
                }

                HStack(spacing: style == .full ? 10 : 6) {
                    Label("\(list.entryCount)", systemImage: "star.fill")
                    Label("\(list.metricCount)", systemImage: "slider.horizontal.3")
                }
                .font(countFont)
                .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
                .labelStyle(.titleAndIcon)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(headerFill)
    }

    private var headerFill: some ShapeStyle {
        LinearGradient(
            colors: [
                ConnoisseurTheme.headerHighlight,
                ConnoisseurTheme.tint(named: list.tintName).opacity(0.08),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var iconSize: CGFloat {
        switch style {
        case .full:
            48
        case .preview:
            34
        }
    }

    private var symbolSize: CGFloat {
        switch style {
        case .full:
            21
        case .preview:
            15
        }
    }

    private var iconSpacing: CGFloat {
        switch style {
        case .full:
            12
        case .preview:
            9
        }
    }

    private var textSpacing: CGFloat {
        switch style {
        case .full:
            5
        case .preview:
            3
        }
    }

    private var horizontalPadding: CGFloat {
        switch style {
        case .full:
            14
        case .preview:
            10
        }
    }

    private var verticalPadding: CGFloat {
        switch style {
        case .full:
            12
        case .preview:
            10
        }
    }

    private var titleFont: Font {
        switch style {
        case .full:
            .system(.title2, design: .rounded, weight: .bold)
        case .preview:
            .system(.subheadline, design: .rounded, weight: .bold)
        }
    }

    private var promptFont: Font {
        switch style {
        case .full:
            .caption.weight(.medium)
        case .preview:
            .caption2.weight(.semibold)
        }
    }

    private var countFont: Font {
        switch style {
        case .full:
            .caption.weight(.semibold)
        case .preview:
            .caption2.weight(.bold)
        }
    }
}

struct RankedListBackground: View {
    let list: RankedList

    var body: some View {
        ConnoisseurTheme.canvas
            .overlay { ConnoisseurTheme.listBackground(tintName: list.tintName) }
            .ignoresSafeArea()
    }
}

struct AllRankingsBackground: View {
    var body: some View {
        ConnoisseurTheme.canvas
            .overlay { ConnoisseurTheme.allListsBackground }
            .ignoresSafeArea()
    }
}
