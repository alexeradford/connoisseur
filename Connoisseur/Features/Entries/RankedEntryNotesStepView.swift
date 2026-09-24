//
//  RankedEntryNotesStepView.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import SwiftUI

struct RankedEntryNotesStepView: View {
    @Binding var notes: String
    let tint: Color

    var body: some View {
        RankedEntryFlowScrollContainer { size in
            VStack(alignment: .leading, spacing: 24) {
                RankedEntryScreenHeader(title: "Anything to remember?")

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $notes)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .padding(14)

                    if notes.isEmpty {
                        Text("Notes")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 19)
                            .padding(.vertical, 22)
                            .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: editorHeight(for: size.height))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(tint.opacity(0.22), lineWidth: 1)
                }
            }
        }
    }

    private func editorHeight(for availableHeight: CGFloat) -> CGFloat {
        max(availableHeight - 190, 320)
    }
}
