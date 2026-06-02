//
//  TabSheetModifier.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import SwiftUI

private struct TabSheetModifier<SheetContent: View>: ViewModifier {
    let isPresented: Bool
    @Binding var selection: TabSheetDetent
    let detents: [TabSheetDetent]
    let horizontalPadding: CGFloat
    let bottomSpacing: CGFloat
    let cornerRadius: CGFloat
    let showsDragIndicator: Bool
    let sheetContent: (TabSheetContext) -> SheetContent
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var liveDragTranslation: CGFloat = 0
    @State private var settlingDragTranslation: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    GeometryReader { proxy in
                        let metrics = tabSheetMetrics(in: proxy)
                        
                        ZStack(alignment: .bottom) {
                            Color.clear
                                .allowsHitTesting(false)
                            
                            tabSheet(for: metrics)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .simultaneousGesture(dragGesture(with: metrics))
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.snappy(duration: 0.28), value: isPresented)
    }
    
    private func tabSheet(for metrics: TabSheetMetrics) -> some View {
        VStack(spacing: 0) {
            if showsDragIndicator {
                Capsule()
                    .fill(.secondary)
                    .frame(width: 38, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .accessibilityHidden(true)
            }
            
            sheetContent(metrics.context)
                // Pin the content to its collapsed width so it doesn't reflow as the
                // sheet animates wider while expanding. The sheet's glass background
                // still fills the full width; the extra space becomes symmetric
                // margin around a fixed-width content area.
                .frame(width: metrics.contentWidth)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .frame(height: metrics.height, alignment: .top)
        .contentShape(Rectangle())
        .glassEffect(.regular, in: .rect(corners: .concentric(minimum: .fixed(cornerRadius))))
        .background(
            .background.opacity(metrics.opaqueBackgroundOpacity),
            in: .rect(corners: .concentric(minimum: .fixed(cornerRadius)))
        )
        .padding(.horizontal, metrics.horizontalMargin)
        .padding(.bottom, metrics.bottomMargin)
    }
    
    private func dragGesture(with metrics: TabSheetMetrics) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .global)
            .updating($liveDragTranslation) { value, state, transaction in
                transaction.disablesAnimations = true
                state = value.translation.height
            }
            .onEnded { value in
                settleDrag(value, metrics: metrics)
            }
    }

    private func settleDrag(_ value: DragGesture.Value, metrics: TabSheetMetrics) {
        let targetDetent = targetDetent(for: value, metrics: metrics)
        preserveReleasePosition(value.translation.height)

        if reduceMotion {
            selection = targetDetent
            settlingDragTranslation = nil
        } else {
            DispatchQueue.main.async {
                withAnimation(.snappy(duration: 0.28)) {
                    selection = targetDetent
                    settlingDragTranslation = 0
                } completion: {
                    settlingDragTranslation = nil
                }
            }
        }
    }
    
    private func preserveReleasePosition(_ translation: CGFloat) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            settlingDragTranslation = translation
        }
    }
    
    private func targetDetent(for value: DragGesture.Value, metrics: TabSheetMetrics) -> TabSheetDetent {
        let detents = metrics.resolvedDetents
        let currentIndex = detents.firstIndex { $0.detent == selection } ?? nearestDetentIndex(
            to: metrics.currentDetentHeight,
            in: detents
        )
        let releaseHeight = metrics.currentDetentHeight - value.translation.height
        let releaseIndex = nearestDetentIndex(to: releaseHeight, in: detents)
        
        if releaseIndex != currentIndex {
            return detents[releaseIndex].detent
        }
        
        let velocityProjection = value.predictedEndTranslation.height - value.translation.height
        let projectedHeight = metrics.currentDetentHeight - value.predictedEndTranslation.height
        let projectedIndex = nearestDetentIndex(to: projectedHeight, in: detents)
        let indexDistance = projectedIndex - currentIndex
        
        guard indexDistance != 0 else {
            return detents[currentIndex].detent
        }
        
        if abs(indexDistance) > 1, abs(velocityProjection) < 760 {
            return detents[currentIndex + (indexDistance > 0 ? 1 : -1)].detent
        }
        
        return detents[projectedIndex].detent
    }
    
    private func tabSheetMetrics(in proxy: GeometryProxy) -> TabSheetMetrics {
        let availableWidth = max(proxy.size.width, 1)
        let availableHeight = max(proxy.size.height + proxy.safeAreaInsets.bottom, 1)
        let largeDetentHeight = availableHeight + largeDetentExtension(for: proxy)
        let resolvedDetents = resolvedDetents(
            in: availableHeight,
            largeDetentHeight: largeDetentHeight
        )
        let currentDetent = resolvedDetents.first { $0.detent == selection } ?? resolvedDetents[0]
        let minHeight = resolvedDetents[0].height
        let maxHeight = resolvedDetents[resolvedDetents.count - 1].height
        let draggedHeight = currentDetent.height - activeDragTranslation
        let height = min(max(draggedHeight, minHeight), maxHeight)
        let progress = if maxHeight > minHeight {
            (height - minHeight) / (maxHeight - minHeight)
        } else {
            CGFloat(0)
        }
        let marginProgress = min(max(progress, 0), 1)
        let selectedIndex = resolvedDetents.firstIndex { $0.detent == currentDetent.detent } ?? 0
        let context = TabSheetContext(
            selectedDetent: currentDetent.detent,
            height: height,
            expansionProgress: progress,
            bottomSafeArea: proxy.safeAreaInsets.bottom,
            isAtSmallestDetent: selectedIndex == 0,
            isAtLargestDetent: selectedIndex == resolvedDetents.count - 1
        )
        
        return TabSheetMetrics(
            resolvedDetents: resolvedDetents,
            currentDetentHeight: currentDetent.height,
            height: height,
            contentWidth: max(availableWidth - horizontalPadding * 2, 0),
            horizontalMargin: horizontalPadding * (1 - marginProgress),
            bottomMargin: bottomSpacing * (1 - marginProgress),
            opaqueBackgroundOpacity: marginProgress,
            context: context
        )
    }
    
    private var activeDragTranslation: CGFloat {
        liveDragTranslation == 0 ? settlingDragTranslation ?? 0 : liveDragTranslation
    }
    
    private func largeDetentExtension(for proxy: GeometryProxy) -> CGFloat {
        max(proxy.safeAreaInsets.top, 72)
    }
    
    private func resolvedDetents(
        in availableHeight: CGFloat,
        largeDetentHeight: CGFloat
    ) -> [(detent: TabSheetDetent, height: CGFloat)] {
        let usableDetents = detents.isEmpty ? [selection] : detents
        
        return usableDetents
            .map { detent in
                (detent: detent, height: resolvedHeight(
                    for: detent,
                    availableHeight: availableHeight,
                    largeDetentHeight: largeDetentHeight
                ))
            }
            .sorted { lhs, rhs in
                lhs.height < rhs.height
            }
    }
    
    private func resolvedHeight(
        for detent: TabSheetDetent,
        availableHeight: CGFloat,
        largeDetentHeight: CGFloat
    ) -> CGFloat {
        switch detent {
        case .large:
            largeDetentHeight
        default:
            detent.resolvedHeight(in: availableHeight)
        }
    }
    
    private func nearestDetent(
        to height: CGFloat,
        in detents: [(detent: TabSheetDetent, height: CGFloat)]
    ) -> (detent: TabSheetDetent, height: CGFloat) {
        detents.min { lhs, rhs in
            abs(lhs.height - height) < abs(rhs.height - height)
        } ?? detents[0]
    }
    
    private func nearestDetentIndex(
        to height: CGFloat,
        in detents: [(detent: TabSheetDetent, height: CGFloat)]
    ) -> Int {
        detents.indices.min { lhs, rhs in
            abs(detents[lhs].height - height) < abs(detents[rhs].height - height)
        } ?? detents.startIndex
    }
}

extension View {
    func tabSheet<SheetContent: View>(
        isPresented: Bool = true,
        selection: Binding<TabSheetDetent>,
        detents: [TabSheetDetent],
        horizontalPadding: CGFloat = 0,
        bottomSpacing: CGFloat = 10,
        cornerRadius: CGFloat = 32,
        showsDragIndicator: Bool = true,
        @ViewBuilder content: @escaping (TabSheetContext) -> SheetContent
    ) -> some View {
        modifier(TabSheetModifier(
            isPresented: isPresented,
            selection: selection,
            detents: detents,
            horizontalPadding: horizontalPadding,
            bottomSpacing: bottomSpacing,
            cornerRadius: cornerRadius,
            showsDragIndicator: showsDragIndicator,
            sheetContent: content
        ))
    }
}
