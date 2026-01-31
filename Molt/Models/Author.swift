import Foundation

struct Author: Codable, Hashable, Sendable {
    let id: String
    let name: String
    let karma: Int?
    let followerCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, karma
        case followerCount = "follower_count"
    }
}
