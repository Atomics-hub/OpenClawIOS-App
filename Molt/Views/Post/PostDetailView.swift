import SwiftUI

struct MarkdownText: View {
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
final class PostDetailViewModel {
    let postId: String
    private(set) var post: MoltbookPost?
    private(set) var comments: [MoltbookComment] = []
    private(set) var isLoading = false
    private(set) var error: APIError?

    init(postId: String) {
        self.postId = postId
    }

    func load() async {
        isLoading = true
        error = nil

        do {
            let response = try await APIClient.shared.fetchPostDetail(id: postId)
            post = response.post
            comments = response.comments

            print("=== DEBUG: Loaded \(comments.count) top-level comments ===")
            for comment in comments.prefix(5) {
                print("\(comment.author.name): \(comment.replies.count) replies")
                for reply in comment.replies.prefix(2) {
                    print("  -> \(reply.author.name): \(reply.replies.count) replies")
                }
            }
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }
}

struct PostDetailView: View {
    let postId: String
    @State private var viewModel: PostDetailViewModel

    init(postId: String) {
        self.postId = postId
        _viewModel = State(initialValue: PostDetailViewModel(postId: postId))
    }

    var body: some View {
        ScrollView {
            if let post = viewModel.post {
                VStack(alignment: .leading, spacing: 0) {
                    PostHeader(post: post)
                        .padding()

                    Divider()

                    if !viewModel.comments.isEmpty {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.comments) { comment in
                                CommentThread(comment: comment, depth: 0)
                            }
                        }
                    } else if !viewModel.isLoading {
                        ContentUnavailableView(
                            "No Comments Yet",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Be the first to comment!")
                        )
                        .padding(.vertical, 40)
                    }
                }
            }
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .overlay {
            if viewModel.isLoading && viewModel.post == nil {
                ProgressView()
            } else if let error = viewModel.error, viewModel.post == nil {
                ContentUnavailableView(
                    "Unable to Load",
                    systemImage: "wifi.slash",
                    description: Text(error.localizedDescription)
                )
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct CommentThread: View {
    let comment: MoltbookComment
    let depth: Int
    @State private var isCollapsed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CommentCell(comment: comment, depth: depth, isCollapsed: $isCollapsed)

            if !isCollapsed {
                ForEach(comment.replies) { reply in
                    CommentThread(comment: reply, depth: depth + 1)
                }
            }
        }
    }
}

struct PostHeader: View {
    let post: MoltbookPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Text(post.submolt.title)
                    .foregroundStyle(.orange)
                Text("·")
                    .foregroundStyle(.tertiary)
                Text("u/\(post.author.name)")
                    .foregroundStyle(.cyan)
            }
            .font(.subheadline)

            Text(post.title)
                .font(.title3)
                .fontWeight(.semibold)

            if let content = post.content, !content.isEmpty {
                MarkdownText(content: content)
                    .font(.body)
            }

            HStack(spacing: 16) {
                HStack(spacing: 3) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .foregroundStyle(.orange)
                    Text("\(post.score)")
                        .fontWeight(.medium)
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundStyle(.blue)
                }
                HStack(spacing: 3) {
                    Image(systemName: "bubble.right")
                        .foregroundStyle(.secondary)
                    Text("\(post.commentCount)")
                }
                Spacer()
                Text(post.createdAt, style: .relative)
                    .foregroundStyle(.tertiary)
            }
            .font(.subheadline)
        }
    }
}

struct CommentCell: View {
    let comment: MoltbookComment
    let depth: Int
    @Binding var isCollapsed: Bool

    private var depthColor: Color {
        let colors: [Color] = [.blue, .orange, .purple, .green, .pink, .cyan]
        return colors[depth % colors.count]
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0..<depth, id: \.self) { index in
                let color: Color = [.blue, .orange, .purple, .green, .pink, .cyan][index % 6]
                Rectangle()
                    .fill(color)
                    .frame(width: 2)
                    .padding(.leading, index == 0 ? 8 : 12)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Text("u/\(comment.author.name)")
                        .fontWeight(.medium)
                        .foregroundStyle(.cyan)
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(comment.createdAt, style: .relative)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if isCollapsed {
                        Text("[+]")
                            .foregroundStyle(.orange)
                    }
                }
                .font(.caption)

                if !isCollapsed {
                    MarkdownText(content: comment.content)
                        .font(.body)

                    HStack(spacing: 4) {
                        Image(systemName: "arrowtriangle.up.fill")
                            .foregroundStyle(.orange)
                        Text("\(comment.score)")
                            .fontWeight(.medium)
                        Image(systemName: "arrowtriangle.down.fill")
                            .foregroundStyle(.blue)
                    }
                    .font(.caption)
                }
            }
            .padding(.leading, depth > 0 ? 12 : 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.light()
            withAnimation(.easeInOut(duration: 0.2)) {
                isCollapsed.toggle()
            }
        }
    }
}
