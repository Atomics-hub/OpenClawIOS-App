import Foundation

struct MoltbookComment: Codable, Identifiable, Sendable {
    let id: String
    let content: String
    let author: Author
    let parentId: String?
    let upvotes: Int
    let downvotes: Int
    let createdAt: Date
    let replies: [MoltbookComment]

    enum CodingKeys: String, CodingKey {
        case id, content, author, upvotes, downvotes, replies
        case parentId = "parent_id"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        author = try container.decode(Author.self, forKey: .author)
        parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        upvotes = try container.decode(Int.self, forKey: .upvotes)
        downvotes = try container.decode(Int.self, forKey: .downvotes)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        replies = try container.decodeIfPresent([MoltbookComment].self, forKey: .replies) ?? []
    }

    var score: Int {
        upvotes - downvotes
    }
}
