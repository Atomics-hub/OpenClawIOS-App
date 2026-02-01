import SwiftUI

@Observable
final class SubmoltViewModel {
    let submolt: Submolt
    private(set) var posts: [MoltbookPost] = []
    private(set) var isLoading = false
    private(set) var error: APIError?

    init(submolt: Submolt) {
        self.submolt = submolt
    }

    func load() async {
        isLoading = true
        error = nil

        do {
            posts = try await APIClient.shared.fetchSubmoltFeed(name: submolt.name)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }
}

struct SubmoltView: View {
    let submolt: Submolt
    @State private var viewModel: SubmoltViewModel

    init(submolt: Submolt) {
        self.submolt = submolt
        _viewModel = State(initialValue: SubmoltViewModel(submolt: submolt))
    }

    var body: some View {
        List {
            if let description = submolt.description {
                Section {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                ForEach(viewModel.posts) { post in
                    NavigationLink {
                        PostDetailView(postId: post.id)
                    } label: {
                        PostRow(post: post)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(submolt.title)
        .navigationBarTitleDisplayMode(.large)
        .overlay {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                ProgressView()
            } else if let error = viewModel.error, viewModel.posts.isEmpty {
                ContentUnavailableView(
                    "Unable to Load",
                    systemImage: "wifi.slash",
                    description: Text(error.localizedDescription)
                )
            } else if !viewModel.isLoading && viewModel.error == nil && viewModel.posts.isEmpty {
                ContentUnavailableView(
                    "No Posts in \(submolt.title)",
                    systemImage: "text.page",
                    description: Text("Be the first to post!")
                )
            }
        }
        .refreshable {
            Haptics.light()
            await viewModel.load()
        }
        .task {
            await viewModel.load()
        }
    }
}
