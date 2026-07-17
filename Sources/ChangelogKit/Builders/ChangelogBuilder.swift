/// A result builder that collects ``ChangelogEntry`` values declared in a
/// trailing closure, supporting conditionals and loops.
@resultBuilder
public enum ChangelogBuilder {

    public static func buildExpression(_ expression: ChangelogEntry) -> [ChangelogEntry] {
        [expression]
    }

    public static func buildExpression(_ expression: [ChangelogEntry]) -> [ChangelogEntry] {
        expression
    }

    public static func buildBlock(_ components: [ChangelogEntry]...) -> [ChangelogEntry] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [ChangelogEntry]?) -> [ChangelogEntry] {
        component ?? []
    }

    public static func buildEither(first component: [ChangelogEntry]) -> [ChangelogEntry] {
        component
    }

    public static func buildEither(second component: [ChangelogEntry]) -> [ChangelogEntry] {
        component
    }

    public static func buildArray(_ components: [[ChangelogEntry]]) -> [ChangelogEntry] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [ChangelogEntry]) -> [ChangelogEntry] {
        component
    }
}

/// A result builder that collects ``ChangelogItem`` values declared in a
/// trailing closure, supporting conditionals and loops.
@resultBuilder
public enum ChangelogItemBuilder {

    public static func buildExpression(_ expression: ChangelogItem) -> [ChangelogItem] {
        [expression]
    }

    public static func buildExpression(_ expression: [ChangelogItem]) -> [ChangelogItem] {
        expression
    }

    public static func buildBlock(_ components: [ChangelogItem]...) -> [ChangelogItem] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [ChangelogItem]?) -> [ChangelogItem] {
        component ?? []
    }

    public static func buildEither(first component: [ChangelogItem]) -> [ChangelogItem] {
        component
    }

    public static func buildEither(second component: [ChangelogItem]) -> [ChangelogItem] {
        component
    }

    public static func buildArray(_ components: [[ChangelogItem]]) -> [ChangelogItem] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [ChangelogItem]) -> [ChangelogItem] {
        component
    }
}
