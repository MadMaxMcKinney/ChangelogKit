import Foundation

/// A lightweight, `Comparable` representation of an app's marketing version.
///
/// `AppVersion` parses a `major.minor.patch` string (the value Apple stores in
/// `CFBundleShortVersionString`). Missing components default to `0`, and any
/// pre-release or build metadata (anything after a `-` or `+`) is ignored for
/// comparison purposes, matching common SemVer expectations.
///
/// ```swift
/// let a: AppVersion = "2.4"      // 2.4.0
/// let b: AppVersion = "2.4.1"
/// a < b                          // true
/// ```
public struct AppVersion: Hashable, Sendable, Comparable, CustomStringConvertible {

    /// The major version component.
    public let major: Int

    /// The minor version component.
    public let minor: Int

    /// The patch version component.
    public let patch: Int

    /// Creates a version from explicit components.
    public init(major: Int, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Creates a version by parsing a `major.minor.patch` string.
    ///
    /// Returns `nil` when the leading component isn't a number. Pre-release and
    /// build metadata (`-beta.1`, `+42`) are stripped before parsing.
    public init?(_ string: String) {
        // Drop any pre-release (`-`) or build metadata (`+`) suffix.
        let core = string.prefix { $0 != "-" && $0 != "+" }
        let components = core.split(separator: ".", omittingEmptySubsequences: false)

        guard let first = components.first, let major = Int(first) else {
            return nil
        }

        func component(at index: Int) -> Int? {
            guard index < components.count else { return 0 }
            return Int(components[index])
        }

        guard let minor = component(at: 1), let patch = component(at: 2) else {
            return nil
        }

        self.init(major: major, minor: minor, patch: patch)
    }

    public var description: String {
        "\(major).\(minor).\(patch)"
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }
}

extension AppVersion: ExpressibleByStringLiteral {
    /// Creates a version from a string literal such as `"2.4.0"`.
    ///
    /// Because literals are authored at compile time, a malformed literal is a
    /// programmer error and resolves to `0.0.0`.
    public init(stringLiteral value: StringLiteralType) {
        self = AppVersion(value) ?? AppVersion(major: 0)
    }
}

extension AppVersion {
    /// The current app version read from `CFBundleShortVersionString`.
    ///
    /// Falls back to `0.0.0` when the value is missing or unparsable (for
    /// example, inside a test bundle).
    public static var current: AppVersion {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let version = AppVersion(raw)
        else {
            return AppVersion(major: 0)
        }
        return version
    }
}
