import Foundation
import WatchKit
import SwiftUI

class MalaViewModel: ObservableObject {
    @Published var currentCount: Int
    @Published var lifetimeTotal: Int
    @Published var isAnimating: Bool = false
    @Published var scale: CGFloat = 1.0
    @Published var isDistractionFree: Bool = false
    @Published var isResetting: Bool = false

    private let countKey = "mala_current_count"
    private let lifetimeKey = "mala_lifetime_total"
    private var crownAccumulator: Double = 0.0
    private var crownDidFire: Bool = false
    private var crownRestTimer: Timer?
    private var resetTimer: Timer?

    init() {
        currentCount = UserDefaults.standard.integer(forKey: "mala_current_count")
        // Migrate lifetimeTotal to shared store if needed
        let sharedTotal = SharedStore.shared.lifetimeTotal
        let localTotal = UserDefaults.standard.integer(forKey: "mala_lifetime_total")
        if sharedTotal == 0 && localTotal > 0 {
            SharedStore.shared.lifetimeTotal = localTotal
        }
        lifetimeTotal = SharedStore.shared.lifetimeTotal
    }

    func increment() {
        let isMilestone = (currentCount + 1) % 108 == 0

        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            currentCount += 1
        }
        lifetimeTotal += 1
        save()

        if isMilestone {
            WKInterfaceDevice.current().play(.success)
            withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                scale = 1.12
            }
        } else {
            WKInterfaceDevice.current().play(.click)
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                scale = 1.06
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                self?.scale = 1.0
            }
        }
    }

    func resetCount() {
        guard currentCount > 0, !isResetting else { return }

        isResetting = true
        let startCount = currentCount
        let duration: Double = 1.5
        let interval: Double = 0.016
        let totalSteps = Int(duration / interval)
        var stepCount = 0

        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }

            stepCount += 1
            let progress = Double(stepCount) / Double(totalSteps)
            let newCount = max(0, Int(Double(startCount) * (1.0 - progress)))

            self.currentCount = newCount

            if stepCount % 20 == 0 {
                WKInterfaceDevice.current().play(.click)
            }

            if stepCount >= totalSteps {
                timer.invalidate()
                WatchSessionManager.shared.sendSession(count: startCount)
                self.currentCount = 0
                self.isResetting = false
                self.save()
                WKInterfaceDevice.current().play(.stop)
            }
        }
    }

    func handleCrownDelta(_ delta: Double) {
        let absDelta = abs(delta)
        guard absDelta > 0 else { return }

        crownAccumulator += absDelta

        // Reset the rest timer — when it fires the gesture is considered over
        crownRestTimer?.invalidate()
        crownRestTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.crownAccumulator = 0
            self?.crownDidFire = false
        }

        // Fire at most one increment per gesture
        if !crownDidFire && crownAccumulator >= 3.0 {
            crownDidFire = true
            increment()
        }
    }

    func toggleDistractionFree() {
        isDistractionFree.toggle()
    }

    private func save() {
        UserDefaults.standard.set(currentCount, forKey: countKey)
        SharedStore.shared.lifetimeTotal = lifetimeTotal
    }
}
