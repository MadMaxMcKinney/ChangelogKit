import Testing
@testable import ChangelogKit

@Suite("AppVersion")
struct AppVersionTests {

    // These tests feed the parser a `String` value rather than a string literal
    // on purpose. `AppVersion("2.4.1")` resolves to the non-failable
    // `init(stringLiteral:)`, so a literal argument would never exercise
    // `init?(_:)` — and would quietly turn a parse failure into 0.0.0.

    @Test("Parses full major.minor.patch")
    func parsesFullVersion() throws {
        let raw: String = "2.4.1"
        let version = try #require(AppVersion(raw))
        #expect(version.major == 2)
        #expect(version.minor == 4)
        #expect(version.patch == 1)
    }

    @Test(
        "Defaults missing components to zero",
        arguments: [
            ("2", AppVersion(major: 2, minor: 0, patch: 0)),
            ("2.4", AppVersion(major: 2, minor: 4, patch: 0))
        ]
    )
    func defaultsMissingComponents(raw: String, expected: AppVersion) throws {
        #expect(try #require(AppVersion(raw)) == expected)
    }

    @Test(
        "Ignores pre-release and build metadata",
        arguments: [
            ("2.4.0-beta.1", AppVersion(major: 2, minor: 4)),
            ("2.4.1+42", AppVersion(major: 2, minor: 4, patch: 1))
        ]
    )
    func ignoresMetadata(raw: String, expected: AppVersion) throws {
        #expect(try #require(AppVersion(raw)) == expected)
    }

    @Test("Returns nil for malformed strings", arguments: ["", "abc", "x.y.z", "2.beta.0", "..", "v2.4.0"])
    func rejectsMalformed(_ raw: String) {
        #expect(AppVersion(raw) == nil)
    }

    @Test("String literal parses at compile time")
    func stringLiteral() {
        let version: AppVersion = "3.1.4"
        #expect(version == AppVersion(major: 3, minor: 1, patch: 4))
    }

    @Test("A malformed literal falls back to 0.0.0")
    func malformedStringLiteral() {
        // Documented behaviour: literals are authored, so a bad one is a
        // programmer error rather than something to propagate as nil.
        let version: AppVersion = "not a version"
        #expect(version == AppVersion(major: 0))
    }

    @Test("Description round-trips")
    func description() {
        #expect(AppVersion(major: 2, minor: 4, patch: 1).description == "2.4.1")
    }

    @Test("Orders by major, then minor, then patch")
    func ordering() {
        let versions: [AppVersion] = ["1.0.0", "2.0.0", "2.3.9", "2.4.0", "2.4.1", "2.9.0", "2.10.0"]
        #expect(versions[0] < versions[1])          // major
        #expect(versions[2] < versions[3])          // minor
        #expect(versions[3] < versions[4])          // patch
        #expect(versions[3] == ("2.4.0" as AppVersion))
        #expect(versions[6] > versions[5])          // numeric, not lexical
    }
}
