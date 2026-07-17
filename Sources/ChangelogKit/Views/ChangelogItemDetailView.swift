import SwiftUI

/// A dedicated screen describing a single ``ChangelogItem`` in depth.
///
/// Pushed from a tappable ``ChangelogItemRow`` when its item carries a
/// non-empty ``ChangelogItemDetail``. The layout mirrors the familiar
/// feature-detail pattern: a large app-icon header, then optional "Overview",
/// "How to Use", and "Available On" sections, each shown only when it has
/// content.
struct ChangelogItemDetailView: View {

    let item: ChangelogItem

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 88

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                header

                if let detail = item.detail {
                    if let overview = detail.overview {
                        section("Overview") {
                            Text(overview)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if !detail.steps.isEmpty {
                        section("How to Use") {
                            steps(detail.steps)
                        }
                    }

                    if !detail.platforms.isEmpty {
                        section("Available On") {
                            platforms(detail.platforms)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 16) {
            ChangelogItemIcon(symbol: item.symbol, tint: item.tint, size: iconSize)

            VStack(spacing: 8) {
                Text(item.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(item.description)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Sections

    /// A titled card wrapping arbitrary content, matching the grouped look of
    /// the reference design.
    private func section(
        _ title: LocalizedStringKey,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func steps(_ steps: [LocalizedStringResource]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Text("\(index + 1)")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(item.tint.map(AnyShapeStyle.init) ?? AnyShapeStyle(.tint), in: .circle)

                    Text(step)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func platforms(_ platforms: [LocalizedStringResource]) -> some View {
        // A wrapping row of capsule "pills", one per platform.
        FlowLayout(spacing: 8) {
            ForEach(Array(platforms.enumerated()), id: \.offset) { _, platform in
                Text(platform)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.fill.tertiary, in: .capsule)
            }
        }
    }
}

/// A minimal flow layout that wraps its subviews onto new lines when they run
/// out of horizontal room — used for the "Available On" platform pills.
private struct FlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = layout(subviews: subviews, maxWidth: maxWidth)
        let height = rows.last.map { $0.y + $0.height } ?? 0
        return CGSize(width: maxWidth == .infinity ? rows.map(\.width).max() ?? 0 : maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = layout(subviews: subviews, maxWidth: bounds.width)
        for row in rows {
            for element in row.elements {
                subviews[element.index].place(
                    at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + row.y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(element.size)
                )
            }
        }
    }

    private struct Row {
        var y: CGFloat = 0
        var height: CGFloat = 0
        var width: CGFloat = 0
        var elements: [(index: Int, x: CGFloat, size: CGSize)] = []
    }

    private func layout(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        var x: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                current.width = x - spacing
                rows.append(current)
                current = Row(y: current.y + current.height + spacing)
                x = 0
            }
            current.elements.append((index, x, size))
            current.height = max(current.height, size.height)
            x += size.width + spacing
        }

        if !current.elements.isEmpty {
            current.width = x - spacing
            rows.append(current)
        }
        return rows
    }
}

#Preview {
    NavigationStack {
        ChangelogItemDetailView(item: .previewDetailed)
    }
    .tint(.blue)
}
