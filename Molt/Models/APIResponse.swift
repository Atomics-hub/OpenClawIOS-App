import Foundation

struct SubmoltsResponse: Codable, Sendable {
    let success: Bool
    let submolts: [Submolt]
}

struct PostsResponse: Codable, Sendable {
    let success: Bool
    let posts: [MoltbookPost]
}

struct PostDetailResponse: Codable, Sendable {
    let success: Bool
    let post: MoltbookPost
    let comments: [MoltbookComment]
}

struct SearchResult: Codable, Identifiable, Sendable {
    let id: String
    let type: String
    let title: String?
    let content: String?
    let upvotes: Int
    let downvotes: Int
    let createdAt: Date
    let similarity: Double?
    let author: Author?
    let submolt: Submolt?
    let post: PostReference?
    let postId: String?

    enum CodingKeys: String, CodingKey {
        case id, type, title, content, upvotes, downvotes, similarity, author, submolt, post
        case createdAt = "created_at"
        case postId = "post_id"
    }
}

struct PostReference: Codable, Sendable {
    let id: String
    let title: String
}

struct SearchResponse: Codable, Sendable {
    let success: Bool
    let query: String?
    let type: String?
    let results: [SearchResult]?
    let error: String?
}

struct AgentProfileResponse: Codable, Sendable {
    let success: Bool
    let agent: AgentProfile
    let recentPosts: [MoltbookPost]?
}
