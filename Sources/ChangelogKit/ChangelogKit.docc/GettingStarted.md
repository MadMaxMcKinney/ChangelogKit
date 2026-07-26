# Getting Started

Author a changelog and present it after an upgrade.

## Author your content

A ``Changelog`` holds one ``ChangelogEntry`` per version, and each entry holds the ``ChangelogItem`` rows shown for it. Entries are sorted newest-first on creation, so declaration order doesn't matter.

```swift
import ChangelogKit

let changelog = Changelog {
    ChangelogEntry(
        version: "2.4.0",
        date: Date(timeIntervalSince1970: 1_752_624_000),
        headline: "Discover the latest features in Example App."
    ) {
        ChangelogItem(
            symbol: "sparkles",
            title: "Smart Suggestions",
            description: "Get intelligent recommendations as you type."
        )
        ChangelogItem(
            symbol: "lock.shield",
            title: "Improved Privacy",
            description: "All processing now happens on device.",
            tint: .green
        )
    }

    ChangelogEntry(version: "2.3.0") {
        ChangelogItem(
            symbol: "paintbrush.fill",
            title: "Fresh Look",
            description: "A redesigned home screen."
        )
    }
}
```

Versions are ``AppVersion`` values, so string literals work: `"2.4"` parses to `2.4.0`. The builders support `if`, `if let`, `switch`, and `for` loops, and both types accept plain arrays (`Changelog(entries:)`, `ChangelogEntry(version:date:headline:items:)`) when you'd rather build content programmatically.

## Present it automatically

Attach the changelog to a long-lived view — usually your root view:

```swift
@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .changelogSheet(changelog)
        }
    }
}
```

The sheet presents when all of these hold:

1. An entry exists for the exact running version, read from `CFBundleShortVersionString`.
2. An earlier version was already recorded. Fresh installs are silently caught up instead, so a brand-new user never sees notes for software they haven't used.
3. The scene is active. The check runs once per launch, never mid-launch transition.

Dismissing the sheet records the current version, so it won't return until you ship a newer one.

Two optional parameters cover the rest: pass `defaults:` to persist state in an app-group suite shared with extensions, and `currentVersion:` to override the running version in previews and tests.

```swift
ContentView()
    .changelogSheet(changelog, currentVersion: "2.4.0")
```

## Present it manually

To drive presentation yourself — a "What's New" row in Settings, say — use the binding overload. It performs no version tracking:

```swift
struct SettingsView: View {
    @State private var isShowingChangelog = false

    var body: some View {
        Button("What's New") { isShowingChangelog = true }
            .changelogSheet(changelog, isPresented: $isShowingChangelog)
    }
}
```

You can also push the views directly. ``ChangelogHistoryView`` lists every authored version:

```swift
NavigationLink("Version History") {
    ChangelogHistoryView(changelog: changelog)
}
```

``ChangelogSheet`` owns its own `NavigationStack`. Create it with `ChangelogSheet(entry:changelog:)` to offer a "See Previous Updates" button — shown only when the changelog has more than one entry — or `ChangelogSheet(entry:)` for a standalone sheet.

## Expand an item into a detail screen

Give an item a ``ChangelogItemDetail`` and its row becomes tappable, pushing a dedicated screen. Every field is optional, and a section renders only when it has content:

```swift
ChangelogItem(
    symbol: "map",
    title: "Improved Radar",
    description: "Higher-res radar with faster updates."
) {
    ChangelogItemDetail(
        overview: "Radar now refreshes up to twice as fast in Europe and Australia.",
        steps: ["Open any location.", "Tap the radar layer."],
        platforms: ["iPhone", "iPad", "Mac"]
    )
}
```

`overview` becomes body copy under "Overview", `steps` a numbered list under "How to Use", and `platforms` a row of capsule pills under "Available On". An empty detail is treated as absent, leaving the row non-interactive. Because the same rows back every surface, detailed items stay tappable in the history view too.

## Track versions yourself

``ChangelogTracker`` is the bookkeeping behind `changelogSheet(_:)`, and it's public if you want full control over presentation:

```swift
let tracker = ChangelogTracker(changelog: changelog)

if tracker.shouldPresent, let entry = tracker.currentEntry {
    // Present ChangelogSheet(entry: entry, changelog: changelog) however you like,
    // then mark it seen:
    tracker.recordCurrentVersion()
}
```

It's `@Observable`, so a `@State` tracker can drive your own views. State persists under ``ChangelogTracker/defaultStorageKey``; to re-test presentation on a device, clear it:

```swift
UserDefaults.standard.removeObject(forKey: ChangelogTracker.defaultStorageKey)
```

## Localize your copy

Titles, descriptions, headlines, steps, and platform names are `LocalizedStringResource`, so literals become localizable keys — add them to your app's string catalog and they resolve in the user's language at display time.

The kit's own labels ("What's New", "See Previous Updates", "Overview", "How to Use", "Available On") are looked up in your app's bundle, so defining those keys localizes or overrides them. The continue button has a dedicated modifier:

```swift
ContentView()
    .changelogSheet(changelog)
    .changelogContinueTitle("Get Started")
```

## See Also

- <doc:Styling>
