//
//  ImagePlaygroundLauncherOverlay.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct ImagePlaygroundLauncherOverlay: View {
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.18))
                .ignoresSafeArea()

            VStack(spacing: 30) {
                ProgressView()
                    .controlSize(.extraLarge)
                    .scaleEffect(1.7)

                VStack(spacing: 10) {
                    Text("Opening Image Playground")
                        .font(.title.bold())

                    Text("The system generator will appear in a moment.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button("Cancel", action: onCancel)
                    .buttonStyle(.bordered)
            }
            .padding(36)
            .frame(width: 380, height: 300)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.22), radius: 30, y: 14)
        }
    }
}
