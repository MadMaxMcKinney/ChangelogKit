import SwiftUI

/// A grouped, card-based list of every authored changelog entry, newest first.
///
/// Public so apps can push it from a "Version History" row in Settings without
/// any of the automatic presentation machinery. Only versions with authored
/// content appear, since ``Changelog/entries`` contains exactly those versions.
///
/// Each version is rendered as a card of ``ChangelogItemRow`` values, so items
/// with a ``ChangelogItemDetail`` remain tappable here just as they are on the
/// current-version sheet.
public struct ChangelogHistoryView: View {

    private let changelog: Changelog

    public init(changelog: Changelog) {
        self.changelog = changelog
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(changelog.entries) { entry in
                    VStack(alignment: .leading, spacing: 12) {
                        header(for: entry)
                        card(for: entry)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Update History")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Version header

    @ViewBuilder
    private func header(for entry: ChangelogEntry) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("VERSION \(entry.version.description)")
                .font(.subheadline.weight(.bold))

            if entry.version == changelog.latest?.version {
                Text("LATEST")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(.systemBackground))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.primary, in: .capsule)
            }

            Spacer(minLength: 8)

            if let date = entry.date {
                Text(date, format: .dateTime.month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Version card

    private func card(for entry: ChangelogEntry) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(entry.items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider()
                        .padding(.leading, 70)
                }
                ChangelogItemRow(item)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

#Preview {
    NavigationStack {
        ChangelogHistoryView(changelog: .preview)
    }
    .tint(.indigo)
}
