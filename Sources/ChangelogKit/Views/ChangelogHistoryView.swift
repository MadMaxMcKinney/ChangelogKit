import SwiftUI

/// A styleable list of every authored changelog entry, newest first.
///
/// Public so apps can push it from a "Version History" row in Settings without
/// any of the automatic presentation machinery. Only versions with authored
/// content appear, since ``Changelog/entries`` contains exactly those versions.
///
/// The appearance is driven by the ``ChangelogHistoryStyle`` in the
/// environment — apply one with the `changelogHistoryStyle(_:)` view modifier.
/// ChangelogKit ships ``ChangelogHistoryStyle/grouped`` (the default),
/// ``ChangelogHistoryStyle/timeline``, ``ChangelogHistoryStyle/collapsible``,
/// and ``ChangelogHistoryStyle/editorial``.
///
/// Whatever the style, each version's rows are ``ChangelogItemRow`` values, so
/// items with a ``ChangelogItemDetail`` remain tappable here just as they are on
/// the current-version sheet.
public struct ChangelogHistoryView: View {

    private let changelog: Changelog

    @Environment(\.changelogHistoryStyle) private var style

    public init(changelog: Changelog) {
        self.changelog = changelog
    }

    public var body: some View {
        style.makeBody(configuration: ChangelogHistoryStyleConfiguration(changelog: changelog))
            .navigationTitle("Update History")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview("Grouped") {
    NavigationStack {
        ChangelogHistoryView(changelog: .preview)
    }
    .tint(.indigo)
}

#Preview("Timeline") {
    NavigationStack {
        ChangelogHistoryView(changelog: .preview)
            .changelogHistoryStyle(.timeline)
    }
    .tint(.indigo)
}

#Preview("Collapsible") {
    NavigationStack {
        ChangelogHistoryView(changelog: .preview)
            .changelogHistoryStyle(.collapsible)
    }
    .tint(.indigo)
}

#Preview("Editorial") {
    NavigationStack {
        ChangelogHistoryView(changelog: .preview)
            .changelogHistoryStyle(.editorial)
    }
    .tint(.indigo)
}
#endif
