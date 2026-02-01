import SwiftUI

struct SearchMarkdownText: View {
    let content: String

    var body: some View {
        if let attributed = try? AttributedString(markdown: content, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attributed)
        } else {
            Text(content)
        }
    }
}

@Observable
final class SearchViewModel {
    var query: String = ""
    private(set) var results: [SearchResult] = []
    private(set) var isLoading = false
    private(set) var error: APIError?
    private(set) var hasSearched = false

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        error = nil
        hasSearched = true

        do {
            let response = try await APIClient.shared.search(query: trimmed)
            results = response.results ?? []
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func clearResults() {
        results = []
        hasSearched = false
        error = nil
    }
}

struct SearchView: View {
    @State private var viewModel: SearchViewModel

    init(initialQuery: String = "") {
        let vm = SearchViewModel()
        vm.query = initialQuery
        _viewModel = State(initialValue: vm)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ContentUnavailableView(
                    "Search Failed",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            } else if viewModel.results.isEmpty {
                if viewModel.hasSearched {
                    ContentUnavailableView.search(text: viewModel.query)
                } else {
                    ContentUnavailableView(
                        "Search Moltbook",
                        systemImage: "magnifyingglass",
                        description: Text("Search for posts, comments, and agents")
                    )
                }
            } else {
                List(viewModel.results) { result in
                    NavigationLink {
                        destinationView(for: result)
                    } label: {
                        SearchResultRow(result: result)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.query, prompt: "Posts, comments, agents...")
        .task(id: viewModel.query) {
            let query = viewModel.query.trimmingCharacters(in: .whitespaces)
            guard !query.isEmpty else {
                viewModel.clearResults()
                return
            }
            if viewModel.hasSearched {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
            }
            await viewModel.search()
        }
    }

    @ViewBuilder
    private func destinationView(for result: SearchResult) -> some View {
        switch result.type.lowercased() {
        case "post":
            PostDetailView(postId: result.id)
        case "comment":
            if let postId = result.postId ?? result.post?.id {
                PostDetailView(postId: postId)
            } else {
                Text("Unable to load post")
            }
        case "submolt":
            if let submolt = result.submolt {
                SubmoltView(submolt: submolt)
            } else {
                Text("Unable to load community")
            }
        default:
            Text("Unknown result type")
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(result.type.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                if let author = result.author {
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(author.name)
                        .foregroundStyle(.secondary)
                }
                Text("·")
                    .foregroundStyle(.tertiary)
                Text(result.createdAt, style: .relative)
                    .foregroundStyle(.tertiary)
            }
            .font(.caption)

            if let title = result.title, !title.isEmpty {
                Text(title)
                    .font(.body)
                    .lineLimit(2)
            }

            if let content = result.content, !content.isEmpty {
                SearchMarkdownText(content: content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if let post = result.post {
                Label(post.title, systemImage: "arrowshape.turn.up.left")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
