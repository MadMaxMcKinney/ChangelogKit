# ``ChangelogKit``

Declare your release notes once and present them as a "What's New" sheet, a browsable version history, and per-feature detail screens.

## Overview

ChangelogKit turns a declarative description of what shipped in each version into three styleable surfaces:

- A **sheet** that presents itself exactly once after a version bump.
- A **history view** listing every authored version, newest first.
- A **detail screen** for any item that carries long-form content.

Author the content with result builders, attach one modifier, and the package handles version tracking in `UserDefaults`:

```swift
let changelog = Changelog {
    ChangelogEntry(version: "2.4.0", headline: "Discover the latest features.") {
        ChangelogItem(
            symbol: "sparkles",
            title: "Smart Suggestions",
            description: "Get intelligent recommendations as you type."
        )
    }
}

ContentView()
    .changelogSheet(changelog)
```

Every surface is restyleable the same way you'd write a `ButtonStyle` — see <doc:Styling>.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Styling>

### Authoring content

- ``Changelog``
- ``ChangelogEntry``
- ``ChangelogItem``
- ``ChangelogItemDetail``
- ``ChangelogBuilder``
- ``ChangelogItemBuilder``

### Presenting

- ``ChangelogSheet``
- ``ChangelogHistoryView``

### Styling the sheet

- ``ChangelogSheetStyle``
- ``ChangelogSheetStyleConfiguration``
- ``GroupedChangelogSheetStyle``
- ``CardsChangelogSheetStyle``
- ``AnyChangelogSheetStyle``

### Styling the history view

- ``ChangelogHistoryStyle``
- ``ChangelogHistoryStyleConfiguration``
- ``GroupedChangelogHistoryStyle``
- ``TimelineChangelogHistoryStyle``
- ``CollapsibleChangelogHistoryStyle``
- ``EditorialChangelogHistoryStyle``
- ``AnyChangelogHistoryStyle``

### Styling item detail screens

- ``ChangelogItemDetailStyle``
- ``ChangelogItemDetailStyleConfiguration``
- ``GroupedChangelogItemDetailStyle``
- ``PlainChangelogItemDetailStyle``
- ``HeroChangelogItemDetailStyle``
- ``AnyChangelogItemDetailStyle``

### Building blocks for custom styles

- ``ChangelogItemRow``
- ``ChangelogItemIcon``
- ``ChangelogDetailSteps``
- ``ChangelogDetailPlatforms``

### Version tracking

- ``AppVersion``
- ``ChangelogTracker``
