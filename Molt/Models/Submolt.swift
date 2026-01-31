import Foundation

struct Submolt: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let displayName: String?
    let description: String?
    let subscriberCount: Int?
    let createdAt: Date?
    let lastActivityAt: Date?
    let featuredAt: Date?
    let createdBy: Author?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case displayName = "display_name"
        case subscriberCount = "subscriber_count"
        case createdAt = "created_at"
        case lastActivityAt = "last_activity_at"
        case featuredAt = "featured_at"
        case createdBy = "created_by"
    }

    var title: String {
        displayName ?? name
    }
}
