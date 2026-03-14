import WatchConnectivity

extension Notification.Name {
    static let watchSessionReceived = Notification.Name("watchSessionReceived")
}

class PhoneSessionManager: NSObject, WCSessionDelegate {
    static let shared = PhoneSessionManager()

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendSettings(numeralStyle: NumeralStyle, fontIsSerif: Bool, fontSizeOption: FontSizeOption) {
        guard WCSession.default.activationState == .activated else { return }
        try? WCSession.default.updateApplicationContext([
            "numeralStyle":   numeralStyle.rawValue,
            "fontIsSerif":    fontIsSerif,
            "fontSizeOption": fontSizeOption.rawValue
        ])
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let idStr  = userInfo["id"]     as? String,
              let uuid   = UUID(uuidString: idStr),
              let ts     = userInfo["date"]   as? TimeInterval,
              let count  = userInfo["count"]  as? Int,
              let srcRaw = userInfo["source"] as? String,
              let source = SessionSource(rawValue: srcRaw) else { return }
        let entry = SessionEntry(id: uuid, date: Date(timeIntervalSince1970: ts), count: count, source: source)
        SharedStore.shared.appendEntry(entry)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .watchSessionReceived, object: nil)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
