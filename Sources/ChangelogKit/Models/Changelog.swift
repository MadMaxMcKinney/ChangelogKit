import Foundation

/// A collection of ``ChangelogEntry`` values, one per authored app version.
///
/// Entries are always kept sorted in descending version order, so
/// ``latest`` and the history view read newest-first without extra work.
public struct Changelog: Sendable {

    /// The authored entries, sorted descending by version.
    public private(set) var entries: [ChangelogEntry]

    /// Creates a changelog from an explicit array of entries.
    public init(entries: [ChangelogEntry]) {
        self.entries = entries.sorted { $0.version > $1.version }
    }

    /// Creates a changelog, declaring its entries with a result builder.
    ///
    /// ```swift
    /// let changelog = Changelog {
    ///     ChangelogEntry(version: "2.4.0") { ... }
    ///     ChangelogEntry(version: "2.3.0") { ... }
    /// }
    /// ```
    public init(@ChangelogBuilder _ entries: () -> [ChangelogEntry]) {
        self.init(entries: entries())
    }

    /// The most recent authored entry, or `nil` when the changelog is empty.
    public var latest: ChangelogEntry? {
        entries.first
    }

    /// Returns the entry authored for an exact version, if one exists.
    public func entry(for version: AppVersion) -> ChangelogEntry? {
        entries.first { $0.version == version }
    }
}
