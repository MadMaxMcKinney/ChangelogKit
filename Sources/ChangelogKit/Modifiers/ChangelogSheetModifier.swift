import SwiftUI

// MARK: - Automatic presentation

/// Presents a changelog sheet automatically after a version upgrade, gating on
/// a ``ChangelogTracker`` and delaying until the scene is active.
private struct AutoChangelogModifier: ViewModifier {

    let changelog: Changelog

    @State private var tracker: ChangelogTracker
    @State private var isPresented = false
    @State private var hasEvaluated = false

    @Environment(\.scenePhase) private var scenePhase

    init(changelog: Changelog, defaults: UserDefaults, currentVersion: AppVersion?) {
        self.changelog = changelog
        _tracker = State(
            initialValue: ChangelogTracker(
                changelog: changelog,
                currentVersion: currentVersion,
                defaults: defaults
            )
        )
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: tracker.recordCurrentVersion) {
                if let entry = tracker.currentEntry {
                    ChangelogSheet(entry: entry, changelog: changelog)
                        .presentationDetents([.large])
                        .presentationBackground(.regularMaterial)
                }
            }
            // Wait until the window is active so we never present mid-launch
            // transition, and evaluate exactly once.
            .onChange(of: scenePhase, initial: true) { _, phase in
                guard phase == .active, !hasEvaluated else { return }
                hasEvaluated = true
                evaluate()
            }
    }

    private func evaluate() {
        if tracker.shouldPresent {
            isPresented = true
        } else if tracker.isFirstLaunch {
            // Fresh install: nothing is "new", so silently catch up.
            tracker.recordCurrentVersion()
        }
    }
}

// MARK: - Manual presentation

/// Presents a changelog sheet driven by an external binding.
private struct BoundChangelogModifier: ViewModifier {

    let changelog: Changelog
    let currentVersion: AppVersion
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            if let entry = changelog.entry(for: currentVersion) ?? changelog.latest {
                ChangelogSheet(entry: entry, changelog: changelog)
                    .presentationDetents([.large])
                    .presentationBackground(.regularMaterial)
            }
        }
    }
}

// MARK: - Public API

extension View {

    /// Automatically presents a "What's New" sheet the first time the app runs
    /// a version that has an authored ``ChangelogEntry``.
    ///
    /// The package owns the bookkeeping: it records the last-presented version
    /// in `UserDefaults`, skips fresh installs, and waits until the scene is
    /// active before presenting.
    ///
    /// ```swift
    /// ContentView()
    ///     .changelogSheet(changelog)
    /// ```
    ///
    /// - Parameters:
    ///   - changelog: The changelog to present.
    ///   - defaults: The `UserDefaults` suite used to persist the last-seen
    ///     version. Inject an app-group suite to share state with extensions.
    ///   - currentVersion: An override for the running app version, useful in
    ///     previews and tests. Defaults to `CFBundleShortVersionString`.
    public func changelogSheet(
        _ changelog: Changelog,
        defaults: UserDefaults = .standard,
        currentVersion: AppVersion? = nil
    ) -> some View {
        modifier(
            AutoChangelogModifier(
                changelog: changelog,
                defaults: defaults,
                currentVersion: currentVersion
            )
        )
    }

    /// Presents a "What's New" sheet under manual control.
    ///
    /// Use this when you want to drive presentation yourself — for example, a
    /// "What's New" row in Settings. No version tracking is performed.
    ///
    /// ```swift
    /// ContentView()
    ///     .changelogSheet(changelog, isPresented: $showChangelog)
    /// ```
    ///
    /// - Parameters:
    ///   - changelog: The changelog to present.
    ///   - isPresented: A binding controlling whether the sheet is shown.
    ///   - currentVersion: The version whose entry to show. Defaults to
    ///     `CFBundleShortVersionString`, falling back to the latest entry.
    public func changelogSheet(
        _ changelog: Changelog,
        isPresented: Binding<Bool>,
        currentVersion: AppVersion = .current
    ) -> some View {
        modifier(
            BoundChangelogModifier(
                changelog: changelog,
                currentVersion: currentVersion,
                isPresented: isPresented
            )
        )
    }
}
