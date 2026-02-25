import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MalaViewModel()
    @Environment(\.colorScheme) var colorScheme

    @State private var crownValue: Double = 0.0
    @State private var lastCrownValue: Double = 0.0
    @State private var pressStartTime: Date?
    @State private var pressTimer: Timer?
    @State private var hasTriggeredReset = false

    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var foregroundColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var rounds: Int {
        viewModel.currentCount / 108
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 6) {
                ZStack {
                    Text("\(viewModel.currentCount)")
                        .font(.system(size: 60, weight: .thin, design: .default))
                        .foregroundColor(foregroundColor)
                        .scaleEffect(viewModel.scale)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: viewModel.scale)
                        .id(viewModel.isResetting ? "reset" : "count_\(viewModel.currentCount)")
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }
                .frame(height: 80)
                .clipped()

                if rounds > 0 {
                    Text("\(rounds) round\(rounds == 1 ? "" : "s")")
                        .font(.system(.footnote, design: .default))
                        .foregroundColor(foregroundColor.opacity(0.6))
                }
            }

            if viewModel.isDistractionFree {
                Color.black.opacity(0.96)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .focusable()
        .digitalCrownRotation(
            $crownValue,
            from: -100000,
            through: 100000,
            by: 1.0,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: false
        )
        .onChange(of: crownValue) { newValue in
            let delta = newValue - lastCrownValue
            lastCrownValue = newValue
            viewModel.handleCrownDelta(delta)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard pressStartTime == nil else { return }
                    pressStartTime = Date()
                    hasTriggeredReset = false
                    pressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        DispatchQueue.main.async {
                            self.hasTriggeredReset = true
                            viewModel.resetCount()
                        }
                    }
                }
                .onEnded { _ in
                    pressTimer?.invalidate()
                    pressTimer = nil
                    defer { pressStartTime = nil }

                    guard let start = pressStartTime, !hasTriggeredReset else { return }
                    let duration = Date().timeIntervalSince(start)
                    if duration >= 0.08 {
                        viewModel.increment()
                    }
                }
        )
        .toolbar {
            ToolbarItem {
                Button(action: { viewModel.toggleDistractionFree() }) {
                    Text("")
                }
                .opacity(0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
