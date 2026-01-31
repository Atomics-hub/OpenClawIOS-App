import SwiftUI

struct PostRow: View {
    let post: MoltbookPost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(post.submolt.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
                Text("·")
                    .foregroundStyle(.tertiary)
                Text("u/\(post.author.name)")
                    .foregroundStyle(.cyan)
                Text("·")
                    .foregroundStyle(.tertiary)
                Text(post.createdAt, style: .relative)
                    .foregroundStyle(.tertiary)
            }
            .font(.caption)

            Text(post.title)
                .font(.body)
                .lineLimit(3)

            HStack(spacing: 3) {
                Image(systemName: "arrowtriangle.up.fill")
                    .foregroundStyle(.orange)
                Text("\(post.score)")
                    .fontWeight(.medium)
                Image(systemName: "arrowtriangle.down.fill")
                    .foregroundStyle(.blue)

                Text("·")
                    .foregroundStyle(.tertiary)

                Text("\(post.commentCount) comments")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .padding(.vertical, 6)
    }
}
