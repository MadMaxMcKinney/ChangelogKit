import Foundation
import Testing
@testable import ChangelogKit

@MainActor
@Suite("ChangelogTracker")
struct ChangelogTrackerTests {

    /// A changelog with content only for 2.4.0.
    private let changelog = Changelog {
        ChangelogEntry(version: "2.4.0") {
            ChangelogItem(symbol: "sparkles", title: "New", description: "New feature.")
        }
    }

    /// Creates a private, empty `UserDefaults` suite for a single test.
    private func makeDefaults() -> UserDefaults {
        let name = "com.changelogkit.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func makeTracker(current: AppVersion, defaults: UserDefaults) -> ChangelogTracker {
        ChangelogTracker(changelog: changelog, currentVersion: current, defaults: defaults)
    }

    @Test("Fresh install does not present and reports first launch")
    func freshInstall() {
        let tracker = makeTracker(current: "2.4.0", defaults: makeDefaults())
        #expect(tracker.isFirstLaunch)
        #expect(tracker.shouldPresent == false)
    }

    @Test("Upgrade with content presents once, then not again")
    func upgradeWithContent() {
        let defaults = makeDefaults()

        let first = makeTracker(current: "2.3.0", defaults: defaults)
        first.recordCurrentVersion() // simulate having seen an earlier version

        let upgraded = makeTracker(current: "2.4.0", defaults: defaults)
        #expect(upgraded.isFirstLaunch == false)
        #expect(upgraded.shouldPresent)

        upgraded.recordCurrentVersion()
        #expect(upgraded.shouldPresent == false)

        // A relaunch on the same version should stay quiet.
        let relaunch = makeTracker(current: "2.4.0", defaults: defaults)
        #expect(relaunch.shouldPresent == false)
    }

    @Test("Upgrade without authored content does not present")
    func upgradeWithoutContent() {
        let defaults = makeDefaults()
        makeTracker(current: "2.4.0", defaults: defaults).recordCurrentVersion()

        // 2.5.0 has no authored entry.
        let upgraded = makeTracker(current: "2.5.0", defaults: defaults)
        #expect(upgraded.shouldPresent == false)
    }

    @Test("Downgrade never presents")
    func downgrade() {
        let defaults = makeDefaults()
        makeTracker(current: "2.4.0", defaults: defaults).recordCurrentVersion()

        // An older build has content but is not newer than the recorded version.
        let downgraded = makeTracker(current: "2.4.0", defaults: defaults)
        #expect(downgraded.shouldPresent == false)
    }

    @Test("Recording persists across tracker instances")
    func persistence() {
        let defaults = makeDefaults()
        makeTracker(current: "2.4.0", defaults: defaults).recordCurrentVersion()

        let reloaded = makeTracker(current: "2.4.0", defaults: defaults)
        #expect(reloaded.lastPresentedVersion == "2.4.0")
    }
}
