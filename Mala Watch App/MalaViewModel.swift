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
    private var resetTimer: Timer?

    init() {
        currentCount = UserDefaults.standard.integer(forKey: "mala_current_count")
        lifetimeTotal = UserDefaults.standard.integer(forKey: "mala_lifetime_total")
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
                self.currentCount = 0
                self.isResetting = false
                self.save()
                WKInterfaceDevice.current().play(.stop)
            }
        }
    }

    func handleCrownDelta(_ delta: Double) {
        guard delta > 0 else { return }
        crownAccumulator += delta
        while crownAccumulator >= 3.0 {
            crownAccumulator -= 3.0
            increment()
        }
    }

    func toggleDistractionFree() {
        isDistractionFree.toggle()
    }

    private func save() {
        UserDefaults.standard.set(currentCount, forKey: countKey)
        UserDefaults.standard.set(lifetimeTotal, forKey: lifetimeKey)
    }
}
