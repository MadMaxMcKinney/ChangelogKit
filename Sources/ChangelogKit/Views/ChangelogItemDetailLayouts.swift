import SwiftUI

// MARK: - Grouped (default)

/// The default detail layout: a large app-icon header, then optional "Overview",
/// "How to Use", and "Available On" sections, each in its own card and each shown
/// only when it has content.
struct GroupedItemDetailLayout: View {

    let configuration: ChangelogItemDetailStyleConfiguration

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 88

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                header

                DetailSections(configuration: configuration) { title, content in
                    ItemDetailCard(title: title) { content }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var header: some View {
        let item = configuration.item

        return VStack(spacing: 16) {
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
}

// MARK: - Plain

/// A card-less detail layout: a smaller icon over a leading-aligned title, then
/// flat sections separated by dividers.
struct PlainItemDetailLayout: View {

    let configuration: ChangelogItemDetailStyleConfiguration

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 60

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                DetailSections(configuration: configuration) { title, content in
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()

                        Text(title)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        content
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var header: some View {
        let item = configuration.item

        return VStack(alignment: .leading, spacing: 16) {
            ChangelogItemIcon(symbol: item.symbol, tint: item.tint, size: iconSize)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.largeTitle.bold())

                Text(item.description)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Hero

/// An expressive detail layout: the icon and title sit on a full-width panel
/// washed in the item's tint, with the sections carded below it.
struct HeroItemDetailLayout: View {

    let configuration: ChangelogItemDetailStyleConfiguration

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 96

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                hero

                DetailSections(configuration: configuration) { title, content in
                    ItemDetailCard(title: title) { content }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var hero: some View {
        let item = configuration.item
        let tint = item.tint ?? .accentColor

        return VStack(spacing: 18) {
            ChangelogItemIcon(symbol: item.symbol, tint: item.tint, size: iconSize)

            VStack(spacing: 8) {
                Text(item.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(item.description)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
        // A soft tint wash that fades into the page rather than ending on a hard
        // edge, so the sections below read as a continuation of the hero.
        .background {
            LinearGradient(
                stops: [
                    .init(color: tint.opacity(0.22), location: 0),
                    .init(color: tint.opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        }
    }
}

// MARK: - Shared section content

/// The section content shared by every built-in layout.
///
/// Emits an "Overview", "How to Use", and "Available On" section — each only when
/// the detail has content for it — handing the heading and body to the layout's
/// own `container` so each style decides how a section is framed.
private struct DetailSections<Container: View>: View {

    let configuration: ChangelogItemDetailStyleConfiguration
    @ViewBuilder let container: (LocalizedStringKey, AnyView) -> Container

    var body: some View {
        let detail = configuration.detail

        VStack(alignment: .leading, spacing: 20) {
            if let overview = detail.overview {
                container("Overview", AnyView(
                    Text(overview)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                ))
            }

            if !detail.steps.isEmpty {
                container("How to Use", AnyView(
                    ChangelogDetailSteps(steps: detail.steps, tint: configuration.item.tint)
                ))
            }

            if !detail.platforms.isEmpty {
                container("Available On", AnyView(
                    ChangelogDetailPlatforms(platforms: detail.platforms)
                ))
            }
        }
    }
}

/// A titled card wrapping arbitrary section content, matching the grouped look
/// used across the kit.
private struct ItemDetailCard<Content: View>: View {

    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

/// A numbered list of instructions, as shown under the built-in styles'
/// "How to Use" heading.
///
/// Public so a custom ``ChangelogItemDetailStyle`` can arrange its own sections
/// without reimplementing the numbered badges.
public struct ChangelogDetailSteps: View {

    private let steps: [LocalizedStringResource]
    private let tint: Color?

    /// Creates a numbered list of steps.
    /// - Parameters:
    ///   - steps: The instructions, rendered in order.
    ///   - tint: The badge accent. Falls back to the environment tint when `nil`.
    public init(steps: [LocalizedStringResource], tint: Color? = nil) {
        self.steps = steps
        self.tint = tint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Text("\(index + 1)")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(tint.map(AnyShapeStyle.init) ?? AnyShapeStyle(.tint), in: .circle)

                    Text(step)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

/// A wrapping row of capsule "pills", one per platform, as shown under the
/// built-in styles' "Available On" heading.
///
/// Public so a custom ``ChangelogItemDetailStyle`` can reuse the pills.
public struct ChangelogDetailPlatforms: View {

    private let platforms: [LocalizedStringResource]

    /// Creates a wrapping row of platform pills.
    public init(platforms: [LocalizedStringResource]) {
        self.platforms = platforms
    }

    public var body: some View {
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
