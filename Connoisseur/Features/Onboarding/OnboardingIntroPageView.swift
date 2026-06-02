//
//  OnboardingIntroPageView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct OnboardingIntroPageView: View {
    let title: String
    let subtitle: String
    let symbolName: String
    let tintName: String
    let detailSymbols: [String]
    let animationValue: Int

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(ConnoisseurTheme.tint(named: tintName).gradient)
                    .frame(width: 128, height: 128)
                    .shadow(color: ConnoisseurTheme.tint(named: tintName).opacity(0.25), radius: 26, y: 14)

                Image(systemName: symbolName)
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: animationValue)
            }

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)

                Text(subtitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 560)
            }

            HStack(spacing: 12) {
                ForEach(detailSymbols, id: \.self) { symbol in
                    Image(systemName: symbol)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(ConnoisseurTheme.tint(named: tintName))
                        .frame(width: 48, height: 48)
                        .background(.regularMaterial, in: Circle())
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
