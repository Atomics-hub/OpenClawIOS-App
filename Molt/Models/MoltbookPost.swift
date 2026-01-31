import Foundation

struct MoltbookPost: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let content: String?
    let author: Author
    let upvotes: Int
    let downvotes: Int
    let commentCount: Int
    let submolt: Submolt
    let createdAt: Date
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id, title, content, author, upvotes, downvotes, submolt, url
        case commentCount = "comment_count"
        case createdAt = "created_at"
    }

    var score: Int {
        upvotes - downvotes
    }
}
