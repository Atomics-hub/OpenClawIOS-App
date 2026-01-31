import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case httpError(Int)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let error): return error.localizedDescription
        case .decodingError(let error): return "Failed to parse response: \(error.localizedDescription)"
        case .httpError(let code): return "Server error: \(code)"
        case .unauthorized: return "Please log in to continue"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatterWithFractional = ISO8601DateFormatter()
            formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatterWithFractional.date(from: dateString) {
                return date
            }

            let formatterWithoutFractional = ISO8601DateFormatter()
            formatterWithoutFractional.formatOptions = [.withInternetDateTime]
            if let date = formatterWithoutFractional.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return decoder
    }()

    private func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainService.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(T.self, from: data)
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    func fetchSubmolts() async throws -> [Submolt] {
        let response: SubmoltsResponse = try await request(.submolts)
        return response.submolts
    }

    func fetchGlobalFeed(sort: String = "hot", limit: Int = 25) async throws -> [MoltbookPost] {
        let response: PostsResponse = try await request(.globalFeed(sort: sort, limit: limit))
        return response.posts
    }

    func fetchSubmoltFeed(name: String) async throws -> [MoltbookPost] {
        let response: PostsResponse = try await request(.submoltFeed(name: name))
        return response.posts
    }

    func fetchPostDetail(id: String) async throws -> PostDetailResponse {
        try await request(.postDetail(id: id))
    }

    func search(query: String) async throws -> SearchResponse {
        try await request(.search(query: query))
    }

    func fetchAgentProfile(name: String) async throws -> AgentProfileResponse {
        try await request(.agentProfile(name: name))
    }
}

