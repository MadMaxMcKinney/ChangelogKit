import Foundation
import Observation

/// Owns the "have we shown this version yet?" bookkeeping for a ``Changelog``.
///
/// The tracker records the last version whose changelog was presented in
/// `UserDefaults`, so a sheet appears exactly once after an upgrade. It reads
/// the current version from `Bundle.main` by default, with overrides for
/// previews and tests.
@MainActor
@Observable
public final class ChangelogTracker {

    /// The version the app is currently running.
    public let currentVersion: AppVersion

    /// The most recent version whose changelog has been presented, or `nil`
    /// when nothing has been recorded yet (a fresh install).
    public private(set) var lastPresentedVersion: AppVersion?

    @ObservationIgnored private let changelog: Changelog
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let storageKey: String

    /// The default `UserDefaults` key under which the last-presented version
    /// is stored.
    public static let defaultStorageKey = "com.changelogkit.lastPresentedVersion"

    /// Creates a tracker.
    /// - Parameters:
    ///   - changelog: The changelog whose presentation is being tracked.
    ///   - currentVersion: An override for the running app version. Defaults to
    ///     `CFBundleShortVersionString` via ``AppVersion/current``.
    ///   - defaults: The `UserDefaults` suite to persist state in. Inject an
    ///     app-group suite to share state across extensions.
    ///   - storageKey: The key used to persist the last-presented version.
    public init(
        changelog: Changelog,
        currentVersion: AppVersion? = nil,
        defaults: UserDefaults = .standard,
        storageKey: String = ChangelogTracker.defaultStorageKey
    ) {
        self.changelog = changelog
        self.defaults = defaults
        self.storageKey = storageKey
        self.currentVersion = currentVersion ?? .current

        if let raw = defaults.string(forKey: storageKey) {
            self.lastPresentedVersion = AppVersion(raw)
        } else {
            self.lastPresentedVersion = nil
        }
    }

    /// `true` when this is the app's first launch with ChangelogKit installed,
    /// i.e. no version has been recorded yet.
    public var isFirstLaunch: Bool {
        lastPresentedVersion == nil
    }

    /// The entry that should be presented for the current version, if any.
    public var currentEntry: ChangelogEntry? {
        changelog.entry(for: currentVersion)
    }

    /// `true` when the changelog for the current version hasn't been shown yet.
    ///
    /// This requires an authored entry for the current version *and* a recorded
    /// earlier version. Fresh installs return `false` — nothing is "new" — and
    /// should call ``recordCurrentVersion()`` to silently catch up.
    public var shouldPresent: Bool {
        guard currentEntry != nil else { return false }
        guard let lastPresentedVersion else { return false }
        return currentVersion > lastPresentedVersion
    }

    /// Marks the current version as seen, persisting it so the changelog won't
    /// present again until a newer version ships.
    public func recordCurrentVersion() {
        lastPresentedVersion = currentVersion
        defaults.set(currentVersion.description, forKey: storageKey)
    }
}
