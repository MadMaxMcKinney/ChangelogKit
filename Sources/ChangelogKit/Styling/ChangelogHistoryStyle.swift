import SwiftUI

// MARK: - Style protocol

/// A type that defines the appearance of a ``ChangelogHistoryView``.
///
/// Conform to `ChangelogHistoryStyle` the same way you'd write a `ButtonStyle`
/// or a ``ChangelogSheetStyle``: implement ``makeBody(configuration:)`` and
/// build a view from the supplied ``ChangelogHistoryStyleConfiguration``. Apply
/// a style with ``SwiftUI/View/changelogHistoryStyle(_:)``.
///
/// ChangelogKit ships four built-in styles: ``grouped`` (the default),
/// ``timeline``, ``collapsible``, and ``editorial``.
@MainActor
public protocol ChangelogHistoryStyle {
    /// A view that represents the body of a changelog history view.
    associatedtype Body: View

    /// Creates the history view's content from the provided configuration.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body

    /// The configuration passed to ``makeBody(configuration:)``.
    typealias Configuration = ChangelogHistoryStyleConfiguration
}

// MARK: - Configuration

/// The properties of a changelog history view, handed to a
/// ``ChangelogHistoryStyle``.
public struct ChangelogHistoryStyleConfiguration {

    /// The changelog whose entries are being listed, sorted newest-first.
    public let changelog: Changelog
}

// MARK: - Built-in styles

/// The default history style: a grouped card of rows per version on a grouped
/// background, matching the ``CardsChangelogSheetStyle`` look.
public struct GroupedChangelogHistoryStyle: ChangelogHistoryStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        GroupedHistoryLayout(changelog: configuration.changelog)
    }
}

/// A history style that hangs each version off a continuous vertical spine,
/// reading like a release history or commit log.
public struct TimelineChangelogHistoryStyle: ChangelogHistoryStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        TimelineHistoryLayout(changelog: configuration.changelog)
    }
}

/// A history style that collapses each version into a one-line summary via a
/// `DisclosureGroup`, expanding the latest version by default. Scales well when
/// the history grows to many versions.
public struct CollapsibleChangelogHistoryStyle: ChangelogHistoryStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        CollapsibleHistoryLayout(changelog: configuration.changelog)
    }
}

/// A history style with large display numerals over an accent rail, giving the
/// history a more expressive, magazine-like feel.
public struct EditorialChangelogHistoryStyle: ChangelogHistoryStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        EditorialHistoryLayout(changelog: configuration.changelog)
    }
}

extension ChangelogHistoryStyle where Self == GroupedChangelogHistoryStyle {
    /// The default history style: a grouped card of rows per version.
    public nonisolated static var grouped: GroupedChangelogHistoryStyle { .init() }
}

extension ChangelogHistoryStyle where Self == TimelineChangelogHistoryStyle {
    /// A history style that hangs each version off a vertical timeline spine.
    public nonisolated static var timeline: TimelineChangelogHistoryStyle { .init() }
}

extension ChangelogHistoryStyle where Self == CollapsibleChangelogHistoryStyle {
    /// A history style that collapses each version behind a disclosure summary.
    public nonisolated static var collapsible: CollapsibleChangelogHistoryStyle { .init() }
}

extension ChangelogHistoryStyle where Self == EditorialChangelogHistoryStyle {
    /// A history style with large display numerals and an accent rail.
    public nonisolated static var editorial: EditorialChangelogHistoryStyle { .init() }
}

// MARK: - Type erasure

/// A type-erased ``ChangelogHistoryStyle`` stored in the environment.
public struct AnyChangelogHistoryStyle {
    private let _makeBody: @MainActor (ChangelogHistoryStyleConfiguration) -> AnyView

    public nonisolated init<S: ChangelogHistoryStyle & Sendable>(_ style: S) {
        self._makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    func makeBody(configuration: ChangelogHistoryStyleConfiguration) -> AnyView {
        _makeBody(configuration)
    }
}

// MARK: - Environment

extension EnvironmentValues {
    /// The style applied to changelog history views in this environment.
    @Entry public var changelogHistoryStyle: AnyChangelogHistoryStyle = AnyChangelogHistoryStyle(.grouped)
}

extension View {
    /// Sets the style for changelog history views within this view.
    ///
    /// Because the history view is pushed from within the ``ChangelogSheet``'s
    /// navigation stack, applying this alongside ``changelogStyle(_:)`` styles
    /// both surfaces:
    ///
    /// ```swift
    /// ContentView()
    ///     .changelogSheet(changelog)
    ///     .changelogStyle(.cards)
    ///     .changelogHistoryStyle(.timeline)
    /// ```
    public func changelogHistoryStyle(_ style: some ChangelogHistoryStyle & Sendable) -> some View {
        environment(\.changelogHistoryStyle, AnyChangelogHistoryStyle(style))
    }
}
