import SwiftUI

struct SessionLogView: View {
    @State private var sessions: [SessionEntry] = []
    @State private var numeralStyle: NumeralStyle = .arabic
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if sessions.isEmpty {
                Text("Your practice will be recorded here.")
                    .italic()
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List(sessions) { entry in
                    SessionRow(entry: entry, numeralStyle: numeralStyle)
                        .listRowBackground(Color.black)
                        .listRowSeparatorTint(.white.opacity(0.08))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear { load() }
        .onChange(of: scenePhase) { if $0 == .active { load() } }
        .onReceive(NotificationCenter.default.publisher(for: .watchSessionReceived)) { _ in load() }
    }

    private func load() {
        sessions     = SharedStore.shared.allSessions()
        numeralStyle = SharedStore.shared.numeralStyle
    }
}

private struct SessionRow: View {
    let entry: SessionEntry
    let numeralStyle: NumeralStyle

    private var rounds: Int { entry.count / 108 }

    private var dateText: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDate(entry.date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMMM d"
        } else {
            formatter.dateFormat = "MMMM d, yyyy"
        }
        return formatter.string(from: entry.date)
    }

    private var sourceLabel: String {
        switch entry.source {
        case .watch: return "Watch"
        case .iphone: return "iPhone"
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(dateText)
                    .font(.system(.subheadline, design: .default))
                    .foregroundColor(.white.opacity(0.5))

                Text("\(entry.count.formatted(as: numeralStyle)) counts")
                    .font(.system(.body, design: .default, weight: .medium))
                    .foregroundColor(.white)

                if rounds > 0 {
                    Text("\(rounds) round\(rounds == 1 ? "" : "s")")
                        .font(.system(.footnote, design: .default))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            Spacer()

            Text(sourceLabel)
                .font(.system(.caption, design: .default))
                .foregroundColor(.white.opacity(0.35))
        }
        .padding(.vertical, 6)
    }
}
