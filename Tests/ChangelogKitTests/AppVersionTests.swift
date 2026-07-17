import Testing
@testable import ChangelogKit

@Suite("AppVersion")
struct AppVersionTests {

    @Test("Parses full major.minor.patch")
    func parsesFullVersion() throws {
        let version = try #require(AppVersion("2.4.1"))
        #expect(version.major == 2)
        #expect(version.minor == 4)
        #expect(version.patch == 1)
    }

    @Test("Defaults missing components to zero")
    func defaultsMissingComponents() throws {
        #expect(try #require(AppVersion("2")) == AppVersion(major: 2, minor: 0, patch: 0))
        #expect(try #require(AppVersion("2.4")) == AppVersion(major: 2, minor: 4, patch: 0))
    }

    @Test("Ignores pre-release and build metadata")
    func ignoresMetadata() throws {
        #expect(try #require(AppVersion("2.4.0-beta.1")) == AppVersion(major: 2, minor: 4))
        #expect(try #require(AppVersion("2.4.1+42")) == AppVersion(major: 2, minor: 4, patch: 1))
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
