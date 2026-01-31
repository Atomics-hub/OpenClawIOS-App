import SwiftUI

@Observable
final class HomeViewModel {
    private(set) var submolts: [Submolt] = []
    private(set) var posts: [MoltbookPost] = []
    private(set) var isLoading = false
    private(set) var error: APIError?

    func load() async {
        isLoading = true
        error = nil

        do {
            async let submoltsTask = APIClient.shared.fetchSubmolts()
            async let postsTask = APIClient.shared.fetchGlobalFeed()
            (submolts, posts) = try await (submoltsTask, postsTask)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }
}

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var searchQuery: String?
    @State private var selectedSubmolt: Submolt?
    @State private var showSubmolts = false

    var body: some View {
        List {
            ForEach(viewModel.posts) { post in
                NavigationLink(value: post) {
                    PostRow(post: post)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("🦞 Moltbook")
        .searchable(text: $searchText, prompt: "Search posts, comments, agents...")
        .onSubmit(of: .search) {
            if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                Haptics.medium()
                searchQuery = searchText
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Haptics.light()
                    showSubmolts = true
                } label: {
                    Image(systemName: "list.bullet")
                }
            }
        }
        .sheet(isPresented: $showSubmolts) {
            NavigationStack {
                Group {
                    if viewModel.submolts.isEmpty {
                        ContentUnavailableView(
                            "No Communities",
                            systemImage: "rectangle.3.group",
                            description: Text("Communities will appear here")
                        )
                    } else {
                        List(viewModel.submolts) { submolt in
                            Button {
                                Haptics.selection()
                                selectedSubmolt = submolt
                                showSubmolts = false
                            } label: {
                                HStack {
                                    Text("#")
                                        .foregroundStyle(.orange)
                                        .fontWeight(.bold)
                                    Text(submolt.title)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if let count = submolt.subscriberCount {
                                        Text("\(count)")
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("Communities")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { showSubmolts = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .navigationDestination(item: $selectedSubmolt) { submolt in
            SubmoltView(submolt: submolt)
        }
        .navigationDestination(item: $searchQuery) { query in
            SearchView(initialQuery: query)
        }
        .navigationDestination(for: MoltbookPost.self) { post in
            PostDetailView(postId: post.id)
        }
        .refreshable {
            Haptics.light()
            await viewModel.load()
        }
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
                    "No Posts Yet",
                    systemImage: "text.page",
                    description: Text("Check back later for new posts")
                )
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
