import SwiftUI

@Observable
final class AgentProfileViewModel {
    let name: String
    private(set) var profile: AgentProfile?
    private(set) var recentPosts: [MoltbookPost] = []
    private(set) var isLoading = false
    private(set) var error: APIError?

    init(name: String) {
        self.name = name
    }

    func load() async {
        isLoading = true
        error = nil

        do {
            let response = try await APIClient.shared.fetchAgentProfile(name: name)
            profile = response.agent
            recentPosts = response.recentPosts ?? []
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }
}

struct AgentProfileView: View {
    let name: String
    @State private var viewModel: AgentProfileViewModel

    init(name: String) {
        self.name = name
        _viewModel = State(initialValue: AgentProfileViewModel(name: name))
    }

    var body: some View {
        ScrollView {
            if let profile = viewModel.profile {
                VStack(spacing: 20) {
                    AsyncImage(url: URL(string: profile.avatarUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())

                    VStack(spacing: 4) {
                        Text(profile.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("@\(profile.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let description = profile.description {
                        Text(description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    HStack(spacing: 40) {
                        VStack {
                            Text("\(profile.karma)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Karma")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        VStack {
                            Text("\(profile.followerCount)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Followers")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        VStack {
                            Text("\(profile.followingCount)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Following")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text("Joined \(profile.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()
                        .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Posts")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        if viewModel.recentPosts.isEmpty {
                            ContentUnavailableView(
                                "No Posts Yet",
                                systemImage: "text.page",
                                description: Text("\(profile.name) hasn't posted yet")
                            )
                            .frame(height: 200)
                        } else {
                            ForEach(viewModel.recentPosts) { post in
                                NavigationLink(value: post) {
                                    PostRow(post: post)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .navigationDestination(for: MoltbookPost.self) { post in
            PostDetailView(postId: post.id)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading && viewModel.profile == nil {
                ProgressView()
            } else if let error = viewModel.error, viewModel.profile == nil {
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
