import Foundation

final class SharedStore {
    static let shared = SharedStore()

    private let defaults: UserDefaults

    private let appGroupID = "group.com.milan.mala"
    private let sessionLogKey    = "mala_session_log"
    private let iPhoneCountKey   = "mala_iphone_current_count"
    private let lifetimeTotalKey = "mala_lifetime_total"
    private let numeralStyleKey  = "mala_numeral_style"
    private let fontSerifKey     = "mala_font_serif"
    private let fontSizeKey      = "mala_font_size"

    private init() {
        defaults = UserDefaults(suiteName: "group.com.milan.mala") ?? .standard
    }

    // MARK: - Session Log

    func appendSession(count: Int, source: SessionSource) {
        guard count > 0 else { return }
        let entry = SessionEntry(id: UUID(), date: Date(), count: count, source: source)
        var entries = rawSessions()
        entries.append(entry)
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: sessionLogKey)
        }
    }

    func appendEntry(_ entry: SessionEntry) {
        var entries = rawSessions()
        guard !entries.contains(where: { $0.id == entry.id }) else { return }
        entries.append(entry)
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: sessionLogKey)
        }
    }

    func allSessions() -> [SessionEntry] {
        return rawSessions().sorted { $0.date > $1.date }
    }

    private func rawSessions() -> [SessionEntry] {
        guard let data = defaults.data(forKey: sessionLogKey),
              let entries = try? JSONDecoder().decode([SessionEntry].self, from: data) else {
            return []
        }
        return entries
    }

    // MARK: - iPhone Count

    var iPhoneCount: Int {
        get { defaults.integer(forKey: iPhoneCountKey) }
        set { defaults.set(newValue, forKey: iPhoneCountKey) }
    }

    // MARK: - Lifetime Total

    var lifetimeTotal: Int {
        get { defaults.integer(forKey: lifetimeTotalKey) }
        set { defaults.set(newValue, forKey: lifetimeTotalKey) }
    }

    // MARK: - Appearance Settings

    var numeralStyle: NumeralStyle {
        get { NumeralStyle(rawValue: defaults.string(forKey: numeralStyleKey) ?? "") ?? .arabic }
        set { defaults.set(newValue.rawValue, forKey: numeralStyleKey) }
    }

    var fontIsSerif: Bool {
        get { defaults.bool(forKey: fontSerifKey) }
        set { defaults.set(newValue, forKey: fontSerifKey) }
    }

    var fontSizeOption: FontSizeOption {
        get { FontSizeOption(rawValue: defaults.string(forKey: fontSizeKey) ?? "") ?? .medium }
        set { defaults.set(newValue.rawValue, forKey: fontSizeKey) }
    }
}
