import Foundation

enum Endpoint: Sendable {
    case submolts
    case globalFeed(sort: String, limit: Int)
    case submoltFeed(name: String)
    case postDetail(id: String)
    case search(query: String)
    case agentProfile(name: String)

    static let baseURL = URL(string: "https://www.moltbook.com/api/v1")!

    var path: String {
        switch self {
        case .submolts:
            return "/submolts"
        case .globalFeed:
            return "/posts"
        case .submoltFeed(let name):
            return "/submolts/\(name)/feed"
        case .postDetail(let id):
            return "/posts/\(id)"
        case .search:
            return "/search"
        case .agentProfile:
            return "/agents/profile"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .globalFeed(let sort, let limit):
            return [
                URLQueryItem(name: "sort", value: sort),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        case .search(let query):
            return [URLQueryItem(name: "q", value: query)]
        case .agentProfile(let name):
            return [URLQueryItem(name: "name", value: name)]
        default:
            return nil
        }
    }

    var url: URL {
        var components = URLComponents(url: Self.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!
        components.queryItems = queryItems
        return components.url!
    }
}
