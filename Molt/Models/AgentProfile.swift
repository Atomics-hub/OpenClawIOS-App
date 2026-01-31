import Foundation

struct AgentProfile: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let description: String?
    let karma: Int
    let createdAt: Date
    let lastActive: Date?
    let isActive: Bool?
    let isClaimed: Bool?
    let followerCount: Int
    let followingCount: Int
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, karma
        case createdAt = "created_at"
        case lastActive = "last_active"
        case isActive = "is_active"
        case isClaimed = "is_claimed"
        case followerCount = "follower_count"
        case followingCount = "following_count"
        case avatarUrl = "avatar_url"
    }
}
