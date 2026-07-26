import SwiftUI

/// A dedicated screen describing a single ``ChangelogItem`` in depth.
///
/// Pushed from a tappable ``ChangelogItemRow`` when its item carries a
/// non-empty ``ChangelogItemDetail``.
///
/// The appearance is driven by the ``ChangelogItemDetailStyle`` in the
/// environment — apply one with the `changelogItemDetailStyle(_:)` view modifier.
/// ChangelogKit ships ``ChangelogItemDetailStyle/grouped`` (the default),
/// ``ChangelogItemDetailStyle/plain``, and ``ChangelogItemDetailStyle/hero``.
struct ChangelogItemDetailView: View {

    let item: ChangelogItem

    @Environment(\.changelogItemDetailStyle) private var style

    var body: some View {
        // `detail` is non-nil in practice: the row only pushes this screen for
        // items whose detail has content. Guarding keeps the style's
        // configuration free of optionality.
        if let detail = item.detail, !detail.isEmpty {
            style.makeBody(
                configuration: ChangelogItemDetailStyleConfiguration(item: item, detail: detail)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Grouped") {
    NavigationStack {
        ChangelogItemDetailView(item: .previewDetailed)
    }
    .tint(.blue)
}

#Preview("Plain") {
    NavigationStack {
        ChangelogItemDetailView(item: .previewDetailed)
            .changelogItemDetailStyle(.plain)
    }
    .tint(.blue)
}

#Preview("Hero") {
    NavigationStack {
        ChangelogItemDetailView(item: .previewDetailed)
            .changelogItemDetailStyle(.hero)
    }
    .tint(.blue)
}
