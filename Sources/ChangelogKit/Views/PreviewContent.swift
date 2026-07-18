#if DEBUG
import Foundation

extension Changelog {
    /// Sample content used by SwiftUI previews.
    static let preview = Changelog {
        ChangelogEntry(
            version: "2.4.0",
            date: Date(timeIntervalSince1970: 1_752_624_000), // 2025-07-16
            headline: "Discover the latest features in Example App."
        ) {
            ChangelogItem(
                symbol: "sparkles",
                title: "Smart Suggestions",
                description: "Get intelligent recommendations as you type.",
            ) {
                ChangelogItemDetail(
                    overview: "Smart Suggestions watches how you write and surfaces the right phrase, snippet, or action inline — no menus, no digging.",
                    steps: [
                        "Start typing anywhere in the app.",
                        "Glance at the suggestion above the keyboard.",
                        "Tap it to accept, or keep typing to dismiss it."
                    ],
                    platforms: ["iPhone", "iPad", "Mac"]
                )
            }
            ChangelogItem(
                symbol: "lock.shield",
                title: "Improved Privacy",
                description: "All processing now happens on device.",
                detail: ChangelogItemDetail(
                    overview: "Nothing you type leaves your device. Suggestions, indexing, and search now run entirely on your hardware.",
                    platforms: ["iPhone", "iPad", "Mac", "Vision Pro"]
                )
            )
            ChangelogItem(
                symbol: "bolt.fill",
                title: "Faster Launches",
                description: "The app now opens up to 40% faster on older devices.",
            )
        }
        ChangelogEntry(
            version: "2.3.0",
            date: Date(timeIntervalSince1970: 1_748_995_200) // 2025-06-04
        ) {
            ChangelogItem(
                symbol: "paintbrush.fill",
                title: "Fresh Look",
                description: "A redesigned home screen built for Liquid Glass.",
                tint: .teal
            )
            ChangelogItem(
                symbol: "arrow.triangle.2.circlepath",
                title: "Background Sync",
                description: "Your changes now sync even when the app is closed."
            )
        }
    }
}

extension ChangelogEntry {
    /// The most recent sample entry used by SwiftUI previews.
    static let preview = Changelog.preview.latest!
}

extension ChangelogItem {
    /// A sample item carrying full detail content, used by the detail preview.
    static let previewDetailed = Changelog.preview.latest!.items[0]
}
#endif
