import Testing
@testable import ChangelogKit

@Suite("Changelog model")
struct ChangelogTests {

    private var sample: Changelog {
        Changelog {
            ChangelogEntry(version: "2.3.0") {
                ChangelogItem(symbol: "star", title: "Old", description: "Old feature.")
            }
            ChangelogEntry(version: "2.4.0") {
                ChangelogItem(symbol: "sparkles", title: "New", description: "New feature.")
                ChangelogItem(symbol: "lock", title: "Privacy", description: "On device.")
            }
        }
    }

    @Test("Entries are sorted descending by version")
    func sortsDescending() {
        let versions: [AppVersion] = ["2.4.0", "2.3.0"]
        #expect(sample.entries.map(\.version) == versions)
    }

    @Test("Latest returns the highest version")
    func latest() {
        #expect(sample.latest?.version == "2.4.0")
    }

    @Test("entry(for:) matches an exact version")
    func entryForExactVersion() {
        let entry = sample.entry(for: "2.4.0")
        #expect(entry?.items.count == 2)
    }

    @Test("entry(for:) returns nil for an unauthored version")
    func entryForMissingVersion() {
        #expect(sample.entry(for: "2.5.0") == nil)
    }

    @Test("Item builder supports conditionals")
    func conditionalItems() {
        let includeExtra = true
        let entry = ChangelogEntry(version: "1.0.0") {
            ChangelogItem(symbol: "a", title: "A", description: "A.")
            if includeExtra {
                ChangelogItem(symbol: "b", title: "B", description: "B.")
            }
        }
        #expect(entry.items.count == 2)
    }
}
