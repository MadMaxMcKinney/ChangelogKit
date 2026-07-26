# ChangelogKit

A SwiftUI package for the "What's New" screen: declare your release notes once, and ChangelogKit presents them after an upgrade, keeps a browsable version history, and expands any entry into a full feature detail screen — all restyleable the same way you'd write a `ButtonStyle`.

- **Declarative content** — author your changelog with result builders, one entry per version.
- **Automatic presentation** — the sheet appears exactly once after a version bump. ChangelogKit owns the `UserDefaults` bookkeeping.
- **Three styleable surfaces** — the sheet, the version history, and per-item detail screens, each with its own style protocol and built-in styles.
- **Localization-ready** — all authored copy is `LocalizedStringResource`.

## Requirements

|               |                              |
|---------------|------------------------------|
| Platforms     | iOS 26+                      |
| Toolchain     | Swift 6.4 / Xcode 27+        |
| Language mode | Swift 6 (strict concurrency) |

## Installation

Add the package in Xcode via **File ▸ Add Package Dependencies…**, or declare it in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/MadMaxMcKinney/ChangelogKit.git", branch: "main")
],
targets: [
    .target(name: "MyApp", dependencies: ["ChangelogKit"])
]
```

The repository has no tagged releases yet, so track `main` for now. Once a release is tagged, prefer pinning to it: `.package(url: …, from: "1.0.0")`.

## Quick start

Author a changelog, then attach it to your root view:

```swift
import SwiftUI
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
}

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

The next time the app runs version `2.4.0` — and only the first time — the sheet presents itself once the scene becomes active.

## Authoring content

### Changelog

A `Changelog` is a list of `ChangelogEntry` values, one per version. Entries are sorted newest-first on init, so declaration order doesn't matter.

```swift
let changelog = Changelog {
    ChangelogEntry(version: "2.4.0") { … }
    ChangelogEntry(version: "2.3.0") { … }
}
```

Both `Changelog` and `ChangelogEntry` also take plain arrays (`Changelog(entries:)`, `ChangelogEntry(version:items:)`) if you'd rather build content programmatically. The builders support `if`, `if let`, `switch`, and `for` loops.

### Entries

| Parameter  | Notes                                                             |
|------------|-------------------------------------------------------------------|
| `version`  | An `AppVersion`. String literals work: `"2.4"` parses to `2.4.0`. |
| `date`     | Optional. Shown in the history view when present.                 |
| `headline` | Optional line beneath the "What's New" title.                     |
| `items`    | The rows for this version.                                        |

### Items

Each `ChangelogItem` is an SF Symbol tile, a title, and a description. `tint` accents the icon for that one row; omit it to inherit the ambient `.tint`.

```swift
ChangelogItem(
    symbol: "bolt.fill",
    title: "Faster Launches",
    description: "The app now opens up to 40% faster on older devices.",
    tint: .orange
)
```

### Item detail screens

Give an item a `ChangelogItemDetail` and its row becomes tappable, pushing a dedicated screen. Every field is optional, and each section only renders when it has content:

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

| Field       | Rendered as                                 |
|-------------|---------------------------------------------|
| `overview`  | Body copy under an "Overview" heading       |
| `steps`     | A numbered list under "How to Use"          |
| `platforms` | Wrapping capsule pills under "Available On" |

An empty detail is treated as absent, so the row stays non-interactive.

## Presenting

### Automatically, after an upgrade

```swift
ContentView()
    .changelogSheet(changelog)
```

The sheet presents when **all** of these hold:

1. There's an entry authored for the exact running version (`CFBundleShortVersionString`).
2. A previous version was already recorded — fresh installs are silently caught up instead, so new users don't get a changelog for software they've never used.
3. The scene is active. The check runs once per launch, never mid-launch transition.

Dismissing records the current version, so it won't return until you ship a newer one.

Optional parameters:

```swift
ContentView()
    .changelogSheet(
        changelog,
        defaults: UserDefaults(suiteName: "group.com.example.app")!,  // share state with extensions
        currentVersion: "2.4.0"                                       // override for previews/tests
    )
```

### Manually, from a Settings row

No version tracking — you own the binding:

```swift
struct SettingsView: View {
    @State private var isShowingChangelog = false

    var body: some View {
        Button("What's New") { isShowingChangelog = true }
            .changelogSheet(changelog, isPresented: $isShowingChangelog)
    }
}
```

By default this shows the entry for the running version, falling back to the latest one. Pass `currentVersion:` to show a specific release.

### The sheet and history views directly

`ChangelogSheet` and `ChangelogHistoryView` are public, so you can push either one yourself:

```swift
NavigationLink("Version History") {
    ChangelogHistoryView(changelog: changelog)
}
```

`ChangelogSheet` owns its own `NavigationStack`. Initialize it with `ChangelogSheet(entry:changelog:)` to offer the "See Previous Updates" button — it appears only when the changelog holds more than one entry — or `ChangelogSheet(entry:)` for a standalone sheet.

### Button copy

```swift
ContentView()
    .changelogSheet(changelog)
    .changelogContinueTitle("Get Started")
```

## Styling

Three surfaces, three style protocols, each applied through the environment and each modeled on `ButtonStyle`. They compose — the history and detail screens are pushed inside the sheet's navigation stack, so one chain styles everything:

```swift
ContentView()
    .changelogSheet(changelog)
    .changelogStyle(.cards)
    .changelogHistoryStyle(.timeline)
    .changelogItemDetailStyle(.hero)
```

### Built-in styles

**`.changelogStyle(_:)`** — the "What's New" sheet:

| Style      | Look                                                    |
|------------|---------------------------------------------------------|
| `.grouped` | Default. Large title over a clean list of rows.         |
| `.cards`   | Each row boxed in its own card on a grouped background. |

**`.changelogHistoryStyle(_:)`** — the version history:

| Style          | Look                                                                      |
|----------------|---------------------------------------------------------------------------|
| `.grouped`     | Default. A card of rows per version.                                      |
| `.timeline`    | Versions hang off a continuous vertical spine, like a commit log.         |
| `.collapsible` | One-line summary per version, expanding on tap. Scales to long histories. |
| `.editorial`   | Large display numerals over an accent rail.                               |

**`.changelogItemDetailStyle(_:)`** — an item's detail screen:

| Style      | Look                                                          |
|------------|---------------------------------------------------------------|
| `.grouped` | Default. Big centered app-icon header, then carded sections.  |
| `.plain`   | No cards: leading-aligned header, divider-separated sections. |
| `.hero`    | Full-width tint wash behind the header, then carded sections. |

### Writing a custom style

Conform to the matching protocol and build a view from the configuration you're handed. For the sheet:

```swift
struct CompactSheetStyle: ChangelogSheetStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            configuration.title.font(.largeTitle.bold())

            ForEach(configuration.entry.items) { item in
                ChangelogItemRow(item)
            }

            Spacer()

            Button(action: configuration.onContinue) {
                configuration.continueLabel.frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if configuration.hasHistory {
                Button("See Previous Updates", action: configuration.onShowHistory)
            }
        }
        .padding(24)
    }
}

ContentView()
    .changelogSheet(changelog)
    .changelogStyle(CompactSheetStyle())
```

…and for a detail screen:

```swift
struct MinimalDetailStyle: ChangelogItemDetailStyle {
    func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChangelogItemIcon(symbol: configuration.item.symbol, tint: configuration.item.tint, size: 64)
                Text(configuration.item.title).font(.largeTitle.bold())

                if let overview = configuration.detail.overview {
                    Text(overview)
                }
                ChangelogDetailSteps(steps: configuration.detail.steps, tint: configuration.item.tint)
                ChangelogDetailPlatforms(platforms: configuration.detail.platforms)
            }
            .padding(24)
        }
    }
}
```

### What each configuration gives you

| `ChangelogSheetStyleConfiguration` |                                         |
|------------------------------------|-----------------------------------------|
| `entry`                            | The version being shown, with its items |
| `title`                            | The "What's New" title, as `Text`       |
| `continueLabel`                    | The primary button's label              |
| `hasHistory`                       | Whether to offer a history affordance   |
| `onContinue`                       | Dismisses and marks the version seen    |
| `onShowHistory`                    | Pushes the history view                 |

| `ChangelogHistoryStyleConfiguration` |                                    |
|--------------------------------------|------------------------------------|
| `changelog`                          | Every authored entry, newest-first |

| `ChangelogItemDetailStyleConfiguration` |                                             |
|-----------------------------------------|---------------------------------------------|
| `item`                                  | The item being described                    |
| `detail`                                | Its long-form content, guaranteed non-empty |

### Reusable building blocks

Custom styles don't have to start from nothing:

| View                                   | Use                                                                                                         |
|----------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `ChangelogItemRow(_:)`                 | The standard icon + title + description row, including the chevron and detail push for items that have one. |
| `ChangelogItemIcon(symbol:tint:size:)` | The app-icon-style tile, at any size.                                                                       |
| `ChangelogDetailSteps(steps:tint:)`    | The numbered instruction list.                                                                              |
| `ChangelogDetailPlatforms(platforms:)` | The wrapping platform pills.                                                                                |

Because the built-in item rows are used at every level, an item with a `ChangelogItemDetail` stays tappable in the history view too.

## Version tracking

`.changelogSheet(_:)` handles this for you, but the machinery is public if you want to drive presentation yourself.

`AppVersion` is a `Comparable` `major.minor.patch` value. Missing components default to `0`, and pre-release/build metadata (`-beta.1`, `+42`) is stripped, so `"2.4-beta.1"` compares equal to `"2.4.0"`.

```swift
let a: AppVersion = "2.4"       // 2.4.0
a < "2.4.1"                     // true
AppVersion.current              // from CFBundleShortVersionString
```

`ChangelogTracker` owns the "have we shown this yet?" state:

```swift
let tracker = ChangelogTracker(changelog: changelog)

if tracker.shouldPresent, let entry = tracker.currentEntry {
    // present ChangelogSheet(entry: entry, changelog: changelog) however you like
    tracker.recordCurrentVersion()
}
```

| Member                   |                                                                |
|--------------------------|----------------------------------------------------------------|
| `currentVersion`         | The running version, or your injected override                 |
| `currentEntry`           | The entry authored for that version, if any                    |
| `isFirstLaunch`          | No version recorded yet                                        |
| `shouldPresent`          | An authored entry exists *and* an earlier version was recorded |
| `lastPresentedVersion`   | What's persisted                                               |
| `recordCurrentVersion()` | Marks the current version as seen                              |

It's `@Observable`, so a `@State` tracker drives your own views directly. State is persisted under `ChangelogTracker.defaultStorageKey`; pass `defaults:` for an app-group suite, or `storageKey:` to change the key.

To re-test presentation on a device, clear the record:

```swift
UserDefaults.standard.removeObject(forKey: ChangelogTracker.defaultStorageKey)
```

## Localization

Titles, descriptions, headlines, steps, and platform names are `LocalizedStringResource`, so string literals become localizable keys — add them to your app's string catalog and they resolve at display time in the user's language.

The kit's own labels ("What's New", "See Previous Updates", "Overview", "How to Use", "Available On") are looked up in your app's bundle, so defining those keys in your catalog localizes or overrides them. The continue button has a dedicated modifier, `.changelogContinueTitle(_:)`.

## Documentation

Full API reference and articles ship as a DocC catalog. Build it in Xcode with **Product ▸ Build Documentation**, or from the command line:

```sh
xcodebuild docbuild -scheme ChangelogKit -destination 'generic/platform=iOS Simulator'
```
