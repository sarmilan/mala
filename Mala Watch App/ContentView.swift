import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MalaViewModel()
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject private var watchSession: WatchSessionManager

    @State private var crownValue: Double = 0.0
    @State private var lastCrownValue: Double = 0.0
    @State private var pressStartTime: Date?
    @State private var pressTimer: Timer?
    @State private var hasTriggeredReset = false
    @State private var viewSize: CGSize = .zero
    @State private var topSafeArea: CGFloat = 0

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
                    Text(viewModel.currentCount.formatted(as: watchSession.numeralStyle))
                        .font(.system(size: watchSession.fontSizeOption.watchFontSize, weight: .thin,
                                      design: watchSession.fontIsSerif ? .serif : .default))
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
            .offset(y: -topSafeArea / 4)

            if viewModel.isDistractionFree {
                Color.black.opacity(0.96)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    viewSize = geo.size
                    topSafeArea = geo.safeAreaInsets.top
                }
            }
        )
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
                .onChanged { value in
                    guard pressStartTime == nil else { return }
                    pressStartTime = Date()
                    hasTriggeredReset = false

                    // Only arm reset if touch started near the count text (center zone).
                    // Corners and edges — where accidental skin contact happens — are excluded.
                    let loc = value.startLocation
                    let cx = viewSize.width / 2
                    let cy = viewSize.height / 2
                    let inResetZone = abs(loc.x - cx) < viewSize.width * 0.38
                                   && abs(loc.y - cy) < viewSize.height * 0.38

                    guard inResetZone else { return }

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
        .persistentSystemOverlays(.hidden)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WatchSessionManager.shared)
    }
}
