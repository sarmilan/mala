import Foundation

struct SessionEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let count: Int
    let source: SessionSource
}

enum SessionSource: String, Codable {
    case watch
    case iphone
}
