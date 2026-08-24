import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A reusable stepper button supporting both single taps and continuous hold with dynamic acceleration.
public struct StepperHoldButton<Content: View>: View {
    private let action: () -> Void
    private let isEnabled: Bool
    private let content: () -> Content
    
    @State private var isPressing: Bool = false
    @State private var loopTask: Task<Void, Never>? = nil
    
    public init(
        isEnabled: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isEnabled = isEnabled
        self.action = action
        self.content = content
    }
    
    public var body: some View {
        content()\
            .opacity(isEnabled ? (isPressing ? 0.7 : 1.0) : 0.4)\
            .scaleEffect(isPressing ? 0.94 : 1.0)\
            .animation(.easeInOut(duration: 0.1), value: isPressing)\
            .contentShape(Rectangle())\
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard isEnabled else { return }
                        if !isPressing {
                            isPressing = true
                            startContinuousAction()
                        }
                    }
                    .onEnded { _ in
                        stopContinuousAction()
                    }
            )
            .onDisappear {
                stopContinuousAction()
            }
    }
    
    private func triggerHapticFeedback() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    private func startContinuousAction() {
        // 1. Instant first trigger
        action()
        triggerHapticFeedback()
        
        // 2. Continuous acceleration loop
        loopTask?.cancel()
        loopTask = Task { @MainActor in
            // Initial wait before repeating
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            var currentIntervalMs: UInt64 = 160
            let minIntervalMs: UInt64 = 40
            let stepReductionMs: UInt64 = 15
            
            while !Task.isCancelled && isPressing {
                action()
                triggerHapticFeedback()
                
                try? await Task.sleep(nanoseconds: currentIntervalMs * 1_000_000)
                
                if currentIntervalMs > minIntervalMs + stepReductionMs {
                    currentIntervalMs -= stepReductionMs
                } else {
                    currentIntervalMs = minIntervalMs
                }
            }
        }
    }
    
    private func stopContinuousAction() {
        isPressing = false
        loopTask?.cancel()
        loopTask = nil
    }
}
