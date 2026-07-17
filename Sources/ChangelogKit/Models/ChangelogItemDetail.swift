import Foundation

/// Optional long-form content shown on a ``ChangelogItem``'s dedicated detail
/// screen.
///
/// When a ``ChangelogItem`` carries a non-empty detail, its row becomes
/// tappable and pushes a ``ChangelogItemDetailView`` — mirroring the way apps
/// like CARROT expand a "What's New" entry into a full explanation of the
/// feature and how to use it.
///
/// Every field is optional; a section only appears when it has content.
///
/// ```swift
/// ChangelogItem(
///     symbol: "map",
///     title: "Improved Radar",
///     description: "Higher-res radar with faster updates."
/// ) {
///     ChangelogItemDetail(
///         overview: "Radar now refreshes up to twice as fast in Europe and Australia.",
///         steps: ["Open any location.", "Tap the radar layer."],
///         platforms: ["iPhone", "iPad", "Mac"]
///     )
/// }
/// ```
public struct ChangelogItemDetail: Sendable {

    /// A longer explanation of the feature, shown under an "Overview" heading.
    public var overview: LocalizedStringResource?

    /// Ordered, numbered instructions shown under a "How to Use" heading.
    public var steps: [LocalizedStringResource]

    /// The platforms the feature is available on, shown as pills under an
    /// "Available On" heading.
    public var platforms: [LocalizedStringResource]

    /// Creates detail content for a changelog item.
    /// - Parameters:
    ///   - overview: A longer explanation of the feature.
    ///   - steps: Ordered instructions for using the feature.
    ///   - platforms: The platforms the feature is available on.
    public init(
        overview: LocalizedStringResource? = nil,
        steps: [LocalizedStringResource] = [],
        platforms: [LocalizedStringResource] = []
    ) {
        self.overview = overview
        self.steps = steps
        self.platforms = platforms
    }

    /// Whether there is any content to show. Empty details are treated as
    /// absent, so the row stays non-interactive.
    var isEmpty: Bool {
        overview == nil && steps.isEmpty && platforms.isEmpty
    }
}
