import SwiftUI

/// A single row in a changelog: an app-icon-style tile on the leading edge,
/// with a title and description trailing it.
///
/// Shared by the current-version sheet and the history view so past entries
/// look identical to new ones. When the item carries a non-empty
/// ``ChangelogItemDetail``, the row shows a chevron and pushes a
/// ``ChangelogItemDetailView`` when tapped.
public struct ChangelogItemRow: View {

    private let item: ChangelogItem
    private let isCarded: Bool

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 54

    public init(_ item: ChangelogItem) {
        self.init(item, isCarded: false)
    }

    /// Creates a row, optionally wrapping it in a self-contained card. Used by
    /// the current-version sheet, where each entry stands alone; containers
    /// that group rows themselves (like the history view) leave this off.
    init(_ item: ChangelogItem, isCarded: Bool) {
        self.item = item
        self.isCarded = isCarded
    }

    public var body: some View {
        if item.hasDetail {
            NavigationLink {
                ChangelogItemDetailView(item: item)
            } label: {
                styledContent
            }
            .buttonStyle(.plain)
        } else {
            styledContent
        }
    }

    @ViewBuilder
    private var styledContent: some View {
        if isCarded {
            content
                .padding(16)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
        } else {
            content
        }
    }

    private var content: some View {
        HStack(alignment: .center, spacing: 16) {
            ChangelogItemIcon(symbol: item.symbol, tint: item.tint, size: iconSize)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.title3.weight(.semibold))
                Text(item.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            if item.hasDetail {
                Image(systemName: "chevron.forward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(item.hasDetail ? .isButton : [])
    }
}

#Preview("Item Row", traits: .sizeThatFitsLayout) {
    NavigationStack {
        VStack(alignment: .leading, spacing: 20) {
            ChangelogItemRow(
                ChangelogItem(
                    symbol: "sparkles",
                    title: "Smart Suggestions",
                    description: "Get intelligent recommendations as you type.",
                    tint: .purple
                ) {
                    ChangelogItemDetail(
                        overview: "Suggestions adapt to how you write.",
                        steps: ["Start typing.", "Tap a suggestion to accept it."],
                        platforms: ["iPhone", "iPad"]
                    )
                }
            )
            ChangelogItemRow(
                ChangelogItem(
                    symbol: "lock.shield",
                    title: "Improved Privacy",
                    description: "All processing now happens on device."
                )
            )
        }
        .padding()
        .tint(.indigo)
    }
}
