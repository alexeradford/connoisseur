//
//  RankedEntryIdentityStepView.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import PhotosUI
import SwiftUI

struct RankedEntryIdentityStepView: View {
    let list: RankedList
    @Binding var draft: RankedEntryDraft
    @Binding var selectedPhotoItems: [PhotosPickerItem]
    let showCameraButton: Bool
    let onCamera: () -> Void

    private var tint: Color {
        ConnoisseurTheme.tint(named: list.tintName)
    }

    var body: some View {
        RankedEntryFlowScrollContainer(bottomPadding: 110) { size in
            VStack(alignment: .leading, spacing: 16) {
                RankedEntryScreenHeader(title: "What are we adding?")

                TextField("Name", text: $draft.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .textFieldStyle(.plain)
                    .submitLabel(.done)
                    .padding(20)
                    .connoisseurField(cornerRadius: 26)

                photoPreview(height: photoHeight(for: size.height))

                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                        Label("Photos", systemImage: "photo.badge.plus")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(tint)

                    if showCameraButton {
                        Button(action: onCamera) {
                            Label("Camera", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(tint)
                    }
                }
                .font(.headline.weight(.bold))

                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private func photoPreview(height: CGFloat) -> some View {
        ZStack {
            if let data = draft.displayPhotoData {
                PhotoThumbnail(data: data)
            } else {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(tint.opacity(0.16))
                    .overlay {
                        Text("Optional photo")
                            .font(.system(.title2, design: .rounded, weight: .semibold))
                            .foregroundStyle(tint)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.45), lineWidth: 1)
        }
    }

    private func photoHeight(for availableHeight: CGFloat) -> CGFloat {
        min(max(availableHeight - 390, 190), 240)
    }
}
