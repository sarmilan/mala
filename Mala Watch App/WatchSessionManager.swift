import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()

    @Published var numeralStyle: NumeralStyle    = SharedStore.shared.numeralStyle
    @Published var fontIsSerif: Bool              = SharedStore.shared.fontIsSerif
    @Published var fontSizeOption: FontSizeOption = SharedStore.shared.fontSizeOption

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendSession(count: Int) {
        let entry = SessionEntry(id: UUID(), date: Date(), count: count, source: .watch)
        SharedStore.shared.appendEntry(entry)
        guard WCSession.default.activationState == .activated else { return }
        WCSession.default.transferUserInfo([
            "id":     entry.id.uuidString,
            "date":   entry.date.timeIntervalSince1970,
            "count":  entry.count,
            "source": entry.source.rawValue
        ])
    }

    func session(_ session: WCSession, didReceiveApplicationContext ctx: [String: Any]) {
        DispatchQueue.main.async {
            if let raw = ctx["numeralStyle"] as? String,    let v = NumeralStyle(rawValue: raw)    { self.numeralStyle   = v; SharedStore.shared.numeralStyle   = v }
            if let v   = ctx["fontIsSerif"]  as? Bool                                              { self.fontIsSerif    = v; SharedStore.shared.fontIsSerif    = v }
            if let raw = ctx["fontSizeOption"] as? String,  let v = FontSizeOption(rawValue: raw)  { self.fontSizeOption = v; SharedStore.shared.fontSizeOption = v }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        guard state == .activated else { return }
        pushLocalSessions()
    }

    private func pushLocalSessions() {
        let watchSessions = SharedStore.shared.allSessions().filter { $0.source == .watch }
        for entry in watchSessions {
            WCSession.default.transferUserInfo([
                "id":     entry.id.uuidString,
                "date":   entry.date.timeIntervalSince1970,
                "count":  entry.count,
                "source": entry.source.rawValue
            ])
        }
    }
}
