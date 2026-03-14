import SwiftUI

struct CounterView: View {
    @State private var currentCount: Int = 0
    @State private var scale: CGFloat = 1.0
    @State private var isResetting = false
    @State private var resetTimer: Timer?
    @State private var numeralStyle: NumeralStyle = .arabic
    @State private var fontIsSerif: Bool = false
    @State private var fontSizeOption: FontSizeOption = .medium
    @Environment(\.scenePhase) private var scenePhase

    private var rounds: Int { currentCount / 108 }
    private var fontDesign: Font.Design { fontIsSerif ? .serif : .default }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 10) {
                Text(currentCount.formatted(as: numeralStyle))
                    .font(.system(size: fontSizeOption.iOSFontSize, weight: .black, design: fontDesign))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .animation(.spring(response: 0.15, dampingFraction: 0.5), value: scale)
                    .modifier(NumericTextTransitionModifier(value: Double(currentCount)))
                    .animation(.default, value: currentCount)

                if rounds > 0 {
                    Text("\(rounds) round\(rounds == 1 ? "" : "s")")
                        .font(.system(.footnote, design: fontDesign))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .onTapGesture {
            guard !isResetting else { return }
            increment()
        }
        .onLongPressGesture(minimumDuration: 0.8) {
            guard !isResetting, currentCount > 0 else { return }
            startReset()
        }
        .onAppear { loadSettings() }
        .onChange(of: scenePhase) { if $0 == .active { loadSettings() } }
    }

    private func loadSettings() {
        currentCount     = SharedStore.shared.iPhoneCount
        numeralStyle     = SharedStore.shared.numeralStyle
        fontIsSerif      = SharedStore.shared.fontIsSerif
        fontSizeOption   = SharedStore.shared.fontSizeOption
    }

    // MARK: - Actions

    private func increment() {
        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
            scale = 1.05
        }
        currentCount += 1
        SharedStore.shared.iPhoneCount = currentCount

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                scale = 1.0
            }
        }
    }

    private func startReset() {
        let startCount = currentCount
        isResetting = true
        let duration: Double = 1.5
        let interval: Double = 0.025
        let totalSteps = Int(duration / interval)
        var stepCount = 0

        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            DispatchQueue.main.async {
                stepCount += 1
                let progress = Double(stepCount) / Double(totalSteps)
                let newCount = max(0, Int(Double(startCount) * (1.0 - progress)))
                currentCount = newCount

                if stepCount % 20 == 0 {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                if stepCount >= totalSteps {
                    timer.invalidate()
                    currentCount = 0
                    SharedStore.shared.appendSession(count: startCount, source: .iphone)
                    SharedStore.shared.iPhoneCount = 0
                    isResetting = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
    }
}
// MARK: - Availability Helper

private struct NumericTextTransitionModifier: ViewModifier {
    let value: Double
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.contentTransition(.numericText(value: value))
        } else {
            content
        }
    }
}

