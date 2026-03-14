import Foundation

enum NumeralStyle: String, CaseIterable {
    case arabic
    case sanskrit

    var displayName: String {
        switch self {
        case .arabic:   return "Arabic"
        case .sanskrit: return "Sanskrit"
        }
    }
}

enum FontSizeOption: String, CaseIterable {
    case small, medium, large, xLarge

    var displayName: String {
        switch self {
        case .small:   return "S"
        case .medium:  return "M"
        case .large:   return "L"
        case .xLarge:  return "XL"
        }
    }

    var watchFontSize: CGFloat {
        switch self {
        case .small:  return 48
        case .medium: return 60
        case .large:  return 72
        case .xLarge: return 84
        }
    }

    var iOSFontSize: CGFloat {
        switch self {
        case .small:  return 64
        case .medium: return 80
        case .large:  return 96
        case .xLarge: return 112
        }
    }
}

extension Int {
    func formatted(as style: NumeralStyle) -> String {
        guard style == .sanskrit else { return "\(self)" }
        let digits = ["०", "१", "२", "३", "४", "५", "६", "७", "८", "९"]
        return String(self).map { c in
            guard let d = c.wholeNumberValue else { return String(c) }
            return digits[d]
        }.joined()
    }
}
