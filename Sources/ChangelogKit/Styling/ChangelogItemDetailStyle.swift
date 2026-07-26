import SwiftUI

// MARK: - Style protocol

/// A type that defines the appearance of a ``ChangelogItem``'s detail screen.
///
/// Conform to `ChangelogItemDetailStyle` the same way you'd write a `ButtonStyle`
/// or a ``ChangelogSheetStyle``: implement ``makeBody(configuration:)`` and build
/// a view from the supplied ``ChangelogItemDetailStyleConfiguration``. Apply a
/// style with the `changelogItemDetailStyle(_:)` view modifier.
///
/// ChangelogKit ships three built-in styles: ``grouped`` (the default),
/// ``plain``, and ``hero``.
@MainActor
public protocol ChangelogItemDetailStyle {
    /// A view that represents the body of an item detail view.
    associatedtype Body: View

    /// Creates the detail view's content from the provided configuration.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body

    /// The configuration passed to ``makeBody(configuration:)``.
    typealias Configuration = ChangelogItemDetailStyleConfiguration
}

// MARK: - Configuration

/// The properties of a changelog item's detail screen, handed to a
/// ``ChangelogItemDetailStyle``.
public struct ChangelogItemDetailStyleConfiguration {

    /// The item being described, including its symbol, title, and tint.
    public let item: ChangelogItem

    /// The item's long-form content. Guaranteed non-empty: a detail screen is
    /// only ever shown for items that carry content.
    public let detail: ChangelogItemDetail
}

// MARK: - Built-in styles

/// The default item detail style: a large centered icon header followed by each
/// section in its own grouped card, matching the ``CardsChangelogSheetStyle``
/// look.
public struct GroupedChangelogItemDetailStyle: ChangelogItemDetailStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        GroupedItemDetailLayout(configuration: configuration)
    }
}

/// An item detail style that drops the cards: a leading-aligned header and
/// plain, left-aligned sections on a standard background. Reads more like a
/// document than a settings screen.
public struct PlainChangelogItemDetailStyle: ChangelogItemDetailStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        PlainItemDetailLayout(configuration: configuration)
    }
}

/// An item detail style that opens with a full-width tinted hero panel behind
/// the icon and title, then lists the sections as grouped cards. More expressive
/// than ``GroupedChangelogItemDetailStyle``, good for marquee features.
public struct HeroChangelogItemDetailStyle: ChangelogItemDetailStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HeroItemDetailLayout(configuration: configuration)
    }
}

extension ChangelogItemDetailStyle where Self == GroupedChangelogItemDetailStyle {
    /// The default item detail style: a centered icon header over grouped cards.
    public nonisolated static var grouped: GroupedChangelogItemDetailStyle { .init() }
}

extension ChangelogItemDetailStyle where Self == PlainChangelogItemDetailStyle {
    /// An item detail style with no cards and a leading-aligned header.
    public nonisolated static var plain: PlainChangelogItemDetailStyle { .init() }
}

extension ChangelogItemDetailStyle where Self == HeroChangelogItemDetailStyle {
    /// An item detail style that opens with a tinted hero panel.
    public nonisolated static var hero: HeroChangelogItemDetailStyle { .init() }
}

// MARK: - Type erasure

/// A type-erased ``ChangelogItemDetailStyle`` stored in the environment.
public struct AnyChangelogItemDetailStyle {
    private let _makeBody: @MainActor (ChangelogItemDetailStyleConfiguration) -> AnyView

    public nonisolated init<S: ChangelogItemDetailStyle & Sendable>(_ style: S) {
        self._makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    func makeBody(configuration: ChangelogItemDetailStyleConfiguration) -> AnyView {
        _makeBody(configuration)
    }
}

// MARK: - Environment

extension EnvironmentValues {
    /// The style applied to changelog item detail views in this environment.
    @Entry public var changelogItemDetailStyle: AnyChangelogItemDetailStyle = AnyChangelogItemDetailStyle(.grouped)
}

extension View {
    /// Sets the style for changelog item detail views within this view.
    ///
    /// Detail screens are pushed from a ``ChangelogItemRow`` inside the
    /// ``ChangelogSheet``'s navigation stack, so applying this alongside the
    /// other style modifiers styles every changelog surface:
    ///
    /// ```swift
    /// ContentView()
    ///     .changelogSheet(changelog)
    ///     .changelogStyle(.cards)
    ///     .changelogHistoryStyle(.timeline)
    ///     .changelogItemDetailStyle(.hero)
    /// ```
    public func changelogItemDetailStyle(_ style: some ChangelogItemDetailStyle & Sendable) -> some View {
        environment(\.changelogItemDetailStyle, AnyChangelogItemDetailStyle(style))
    }
}
