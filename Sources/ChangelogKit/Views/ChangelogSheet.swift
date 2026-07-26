import SwiftUI

/// A "What's New" sheet for a single app version.
///
/// Use this directly when you want full control over presentation — for
/// example, pushing it from a Settings screen. For automatic version-gated
/// presentation, prefer the `changelogSheet(_:defaults:currentVersion:)` view
/// modifier.
///
/// The sheet owns its own `NavigationStack`, so a "See Previous Updates" button
/// pushes ``ChangelogHistoryView`` rather than presenting a second sheet.
public struct ChangelogSheet: View {

    private let entry: ChangelogEntry
    private let changelog: Changelog?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.changelogSheetStyle) private var style
    @Environment(\.changelogContinueTitle) private var continueTitle

    @State private var isShowingHistory = false

    /// Creates a sheet for a single entry.
    public init(entry: ChangelogEntry) {
        self.entry = entry
        self.changelog = nil
    }

    /// Creates a sheet for an entry, offering a link to the full history.
    ///
    /// The "See Previous Updates" affordance appears only when `changelog`
    /// contains more than the entry itself.
    public init(entry: ChangelogEntry, changelog: Changelog) {
        self.entry = entry
        self.changelog = changelog
    }

    public var body: some View {
        NavigationStack {
            style.makeBody(configuration: configuration)
                .navigationDestination(isPresented: $isShowingHistory) {
                    if let changelog {
                        ChangelogHistoryView(changelog: changelog)
                    }
                }
        }
    }

    private var hasHistory: Bool {
        guard let changelog else { return false }
        return changelog.entries.count > 1
    }

    private var configuration: ChangelogSheetStyleConfiguration {
        ChangelogSheetStyleConfiguration(
            entry: entry,
            title: Text("What's New"),
            continueLabel: Text(continueTitle),
            hasHistory: hasHistory,
            onContinue: { dismiss() },
            onShowHistory: { isShowingHistory = true }
        )
    }
}

#Preview("Grouped") {
    ChangelogSheet(entry: .preview, changelog: .preview)
        .tint(.indigo)
}

#Preview("Cards") {
    ChangelogSheet(entry: .preview, changelog: .preview)
        .changelogStyle(.cards)
        .changelogHistoryStyle(.editorial)
        .tint(.indigo)
}
