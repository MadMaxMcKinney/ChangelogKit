import SwiftUI

/// A single row in a changelog sheet: an SF Symbol, a title, and a description.
///
/// This mirrors the familiar "What's New" layout Apple uses across its own apps.
public struct ChangelogItem: Identifiable, Sendable {

    public let id = UUID()

    /// The name of the SF Symbol shown at the leading edge of the row.
    public var symbol: String

    /// The item's title, rendered in a `.headline` font.
    public var title: LocalizedStringResource

    /// The item's supporting description, rendered in secondary text.
    public var description: LocalizedStringResource

    /// An optional per-item accent applied to the icon. Falls back to the
    /// environment's tint when `nil`.
    public var tint: Color?

    /// Optional long-form content. When non-empty, the row becomes tappable and
    /// pushes a dedicated detail screen.
    public var detail: ChangelogItemDetail?

    /// Creates a changelog item.
    /// - Parameters:
    ///   - symbol: The SF Symbol name shown at the leading edge.
    ///   - title: The item's title.
    ///   - description: The item's supporting description.
    ///   - tint: An optional accent for the icon.
    ///   - detail: Optional long-form content for a dedicated detail screen.
    public init(
        symbol: String,
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        tint: Color? = nil,
        detail: ChangelogItemDetail? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.description = description
        self.tint = tint
        self.detail = detail
    }

    /// Creates a changelog item, declaring its detail content in a trailing
    /// closure.
    ///
    /// ```swift
    /// ChangelogItem(
    ///     symbol: "map",
    ///     title: "Improved Radar",
    ///     description: "Higher-res radar with faster updates."
    /// ) {
    ///     ChangelogItemDetail(overview: "Radar now refreshes twice as fast.")
    /// }
    /// ```
    public init(
        symbol: String,
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        tint: Color? = nil,
        detail: () -> ChangelogItemDetail
    ) {
        self.init(
            symbol: symbol,
            title: title,
            description: description,
            tint: tint,
            detail: detail()
        )
    }

    /// Whether this item has long-form content worth pushing a detail screen for.
    var hasDetail: Bool {
        detail.map { !$0.isEmpty } ?? false
    }
}
