# Styling

Restyle the sheet, the version history, and item detail screens — or replace their layouts entirely.

## Overview

ChangelogKit has three styleable surfaces, each with a style protocol modeled on `ButtonStyle`: ``ChangelogSheetStyle``, ``ChangelogHistoryStyle``, and ``ChangelogItemDetailStyle``. Styles travel through the environment, and because the history and detail screens are pushed inside the sheet's own navigation stack, one chain of modifiers styles everything:

```swift
ContentView()
    .changelogSheet(changelog)
    .changelogStyle(.cards)
    .changelogHistoryStyle(.timeline)
    .changelogItemDetailStyle(.hero)
```

Each modifier applies independently, so you can mix a built-in style on one surface with a custom style on another.

## Built-in styles

The sheet, via `changelogStyle(_:)`:

| Style | Look |
|---|---|
| ``ChangelogSheetStyle/grouped`` | Default. Large title over a clean list of rows. |
| ``ChangelogSheetStyle/cards`` | Each row boxed in its own card on a grouped background. |

The version history, via `changelogHistoryStyle(_:)`:

| Style | Look |
|---|---|
| ``ChangelogHistoryStyle/grouped`` | Default. A card of rows per version. |
| ``ChangelogHistoryStyle/timeline`` | Versions hang off a continuous vertical spine, like a commit log. |
| ``ChangelogHistoryStyle/collapsible`` | A one-line summary per version, expanding on tap. Scales to long histories. |
| ``ChangelogHistoryStyle/editorial`` | Large display numerals over an accent rail. |

Item detail screens, via `changelogItemDetailStyle(_:)`:

| Style | Look |
|---|---|
| ``ChangelogItemDetailStyle/grouped`` | Default. Big centered app-icon header, then carded sections. |
| ``ChangelogItemDetailStyle/plain`` | No cards: leading-aligned header, divider-separated sections. |
| ``ChangelogItemDetailStyle/hero`` | Full-width tint wash behind the header, then carded sections. |

## Writing a custom style

Conform to the relevant protocol, implement `makeBody(configuration:)`, and build whatever view you want from the configuration you're handed. Nothing about the built-in layout is load-bearing — you can replace it wholesale.

A custom sheet style receives the entry plus the actions the sheet needs to remain functional:

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
```

Wire it up the same way as a built-in style:

```swift
ContentView()
    .changelogSheet(changelog)
    .changelogStyle(CompactSheetStyle())
```

A custom detail style receives the item and its non-optional long-form content:

```swift
struct MinimalDetailStyle: ChangelogItemDetailStyle {
    func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChangelogItemIcon(
                    symbol: configuration.item.symbol,
                    tint: configuration.item.tint,
                    size: 64
                )
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

### What each configuration provides

``ChangelogSheetStyleConfiguration``:

| Property | |
|---|---|
| ``ChangelogSheetStyleConfiguration/entry`` | The version being shown, with its items |
| ``ChangelogSheetStyleConfiguration/title`` | The "What's New" title, as `Text` |
| ``ChangelogSheetStyleConfiguration/continueLabel`` | The primary button's label |
| ``ChangelogSheetStyleConfiguration/hasHistory`` | Whether to offer a history affordance |
| ``ChangelogSheetStyleConfiguration/onContinue`` | Dismisses and marks the version seen |
| ``ChangelogSheetStyleConfiguration/onShowHistory`` | Pushes the history view |

``ChangelogHistoryStyleConfiguration`` carries ``ChangelogHistoryStyleConfiguration/changelog``: every authored entry, newest-first.

``ChangelogItemDetailStyleConfiguration`` carries ``ChangelogItemDetailStyleConfiguration/item`` and ``ChangelogItemDetailStyleConfiguration/detail``. The detail is guaranteed non-empty, since a detail screen is only ever shown for items that have content.

## Reusable building blocks

Custom styles don't have to start from nothing. These views are public so you can keep the kit's look where you want it and diverge where you don't:

| View | Use |
|---|---|
| ``ChangelogItemRow`` | The standard icon + title + description row, including the chevron and detail push for items that have one. |
| ``ChangelogItemIcon`` | The app-icon-style tile, at any size. |
| ``ChangelogDetailSteps`` | The numbered instruction list. |
| ``ChangelogDetailPlatforms`` | The wrapping platform pills. |

## Tinting

Icon tiles, step badges, and accent rails fall back to the ambient `.tint`, so setting it once colors every surface:

```swift
ContentView()
    .changelogSheet(changelog)
    .tint(.indigo)
```

Set ``ChangelogItem/tint`` on an individual item to override it for that row and its detail screen.

## See Also

- <doc:GettingStarted>
