import SwiftUI

// MARK: - Style protocol

/// A type that defines the appearance of a ``ChangelogSheet``.
///
/// Conform to `ChangelogSheetStyle` the same way you'd write a `ButtonStyle`:
/// implement ``makeBody(configuration:)`` and build a view from the supplied
/// ``ChangelogSheetStyleConfiguration``. Apply a style with
/// ``SwiftUI/View/changelogStyle(_:)``.
///
/// ChangelogKit ships two built-in styles: ``automatic`` and ``prominent``.
@MainActor
public protocol ChangelogSheetStyle {
    /// A view that represents the body of a changelog sheet.
    associatedtype Body: View

    /// Creates the sheet's content from the provided configuration.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body

    /// The configuration passed to ``makeBody(configuration:)``.
    typealias Configuration = ChangelogSheetStyleConfiguration
}

// MARK: - Configuration

/// The properties of a changelog sheet, handed to a ``ChangelogSheetStyle``.
public struct ChangelogSheetStyleConfiguration {

    /// The version whose changes are being shown.
    public let entry: ChangelogEntry

    /// The large title shown at the top of the sheet ("What's New").
    public let title: Text

    /// The label for the primary continue button.
    public let continueLabel: Text

    /// Whether a "See Previous Updates" affordance should be offered.
    public let hasHistory: Bool

    /// Dismisses the sheet, marking the current version as seen.
    public let onContinue: () -> Void

    /// Pushes the version history view.
    public let onShowHistory: () -> Void
}

// MARK: - Built-in styles

/// The default changelog style: a centered title with a clean list of items.
public struct AutomaticChangelogSheetStyle: ChangelogSheetStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ChangelogSheetLayout(configuration: configuration, isProminent: false)
    }
}

/// A bolder changelog style with a larger header and heavier emphasis.
public struct ProminentChangelogSheetStyle: ChangelogSheetStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ChangelogSheetLayout(configuration: configuration, isProminent: true)
    }
}

extension ChangelogSheetStyle where Self == AutomaticChangelogSheetStyle {
    /// The default changelog style.
    public nonisolated static var automatic: AutomaticChangelogSheetStyle { .init() }
}

extension ChangelogSheetStyle where Self == ProminentChangelogSheetStyle {
    /// A bolder changelog style with a larger header.
    public nonisolated static var prominent: ProminentChangelogSheetStyle { .init() }
}

// MARK: - Type erasure

/// A type-erased ``ChangelogSheetStyle`` stored in the environment.
public struct AnyChangelogSheetStyle {
    private let _makeBody: @MainActor (ChangelogSheetStyleConfiguration) -> AnyView

    public nonisolated init<S: ChangelogSheetStyle & Sendable>(_ style: S) {
        self._makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    func makeBody(configuration: ChangelogSheetStyleConfiguration) -> AnyView {
        _makeBody(configuration)
    }
}

// MARK: - Environment

extension EnvironmentValues {
    /// The style applied to changelog sheets in this environment.
    @Entry public var changelogSheetStyle: AnyChangelogSheetStyle = AnyChangelogSheetStyle(.automatic)

    /// The label used for the primary continue button.
    @Entry public var changelogContinueTitle: LocalizedStringKey = "Continue"
}

extension View {
    /// Sets the style for changelog sheets within this view.
    ///
    /// ```swift
    /// ContentView()
    ///     .changelogSheet(changelog)
    ///     .changelogStyle(.prominent)
    /// ```
    public func changelogStyle(_ style: some ChangelogSheetStyle & Sendable) -> some View {
        environment(\.changelogSheetStyle, AnyChangelogSheetStyle(style))
    }

    /// Overrides the label of the changelog's continue button.
    public func changelogContinueTitle(_ title: LocalizedStringKey) -> some View {
        environment(\.changelogContinueTitle, title)
    }
}
