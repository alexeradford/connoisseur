//
//  RankedEntryFlowComponents.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import SwiftUI

struct RankedEntryFlowPrimaryButton: View {
    let title: String
    let tint: Color
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(buttonBackground, in: Capsule())
                .shadow(color: tint.opacity(isDisabled ? 0 : 0.32), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.45 : 1)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private var buttonBackground: LinearGradient {
        LinearGradient(
            colors: [
                tint.opacity(isDisabled ? 0.55 : 0.95),
                tint.mix(with: .black, by: 0.18).opacity(isDisabled ? 0.55 : 1),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct RankedEntryScreenHeader: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 36, weight: .bold))
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RankedEntryFlowScrollContainer<Content: View>: View {
    let bottomPadding: CGFloat
    private let content: (CGSize) -> Content

    init(bottomPadding: CGFloat = 122, @ViewBuilder content: @escaping (CGSize) -> Content) {
        self.bottomPadding = bottomPadding
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content(proxy.size)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(minHeight: proxy.size.height, alignment: .topLeading)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, bottomPadding)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}
