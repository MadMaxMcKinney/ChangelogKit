import SwiftUI

/// The set of changes shipped in a single app version.
public struct ChangelogEntry: Identifiable, Sendable {

    /// The version these changes shipped in. Doubles as the stable identity.
    public var version: AppVersion

    /// The release date, shown in the history view when present.
    public var date: Date?

    /// An optional headline shown beneath the "What's New" title,
    /// for example `"What's New in Springboard"`.
    public var headline: LocalizedStringResource?

    /// The individual rows shown for this version.
    public var items: [ChangelogItem]

    public var id: AppVersion { version }

    /// Creates an entry from an explicit array of items.
    public init(
        version: AppVersion,
        date: Date? = nil,
        headline: LocalizedStringResource? = nil,
        items: [ChangelogItem]
    ) {
        self.version = version
        self.date = date
        self.headline = headline
        self.items = items
    }

    /// Creates an entry, declaring its items with a result builder.
    ///
    /// ```swift
    /// ChangelogEntry(version: "2.4.0") {
    ///     ChangelogItem(symbol: "sparkles",
    ///                   title: "Smart Suggestions",
    ///                   description: "Get intelligent recommendations as you type.")
    /// }
    /// ```
    public init(
        version: AppVersion,
        date: Date? = nil,
        headline: LocalizedStringResource? = nil,
        @ChangelogItemBuilder items: () -> [ChangelogItem]
    ) {
        self.init(version: version, date: date, headline: headline, items: items())
    }
}
