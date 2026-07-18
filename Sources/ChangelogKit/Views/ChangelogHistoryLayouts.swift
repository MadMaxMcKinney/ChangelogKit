import SwiftUI

// MARK: - Grouped (default)

/// The default history layout: a header plus a grouped card of
/// ``ChangelogItemRow`` values per version, newest first.
struct GroupedHistoryLayout: View {

    let changelog: Changelog

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(changelog.entries) { entry in
                    VStack(alignment: .leading, spacing: 12) {
                        header(for: entry)
                        card(for: entry)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    @ViewBuilder
    private func header(for entry: ChangelogEntry) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("VERSION \(entry.version.description)")
                .font(.subheadline.weight(.bold))

            if entry.version == changelog.latest?.version {
                Text("LATEST")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(.systemBackground))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.primary, in: .capsule)
            }

            Spacer(minLength: 8)

            if let date = entry.date {
                Text(date, format: .dateTime.month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    private func card(for entry: ChangelogEntry) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(entry.items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider()
                        .padding(.leading, 70)
                }
                ChangelogItemRow(item)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

// MARK: - Timeline

/// A vertical timeline: each version hangs off a continuous spine with a dot,
/// reading like a release history or commit log. The latest version's dot is
/// filled with the tint; older ones are hollow.
struct TimelineHistoryLayout: View {

    let changelog: Changelog

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(changelog.entries.enumerated()), id: \.element.id) { index, entry in
                    row(for: entry, isLast: index == changelog.entries.count - 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func row(for entry: ChangelogEntry, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 16) {
            rail(isLatest: entry.version == changelog.latest?.version, isLast: isLast)

            VStack(alignment: .leading, spacing: 12) {
                header(for: entry)
                card(for: entry)
            }
            .padding(.bottom, isLast ? 0 : 28)
        }
    }

    /// The leading spine: a dot at the version's baseline with a line that
    /// fills the remaining height, connecting to the next version.
    private func rail(isLatest: Bool, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: 2)
                .background(Circle().fill(isLatest ? Color.accentColor : Color(.systemGroupedBackground)))
                .frame(width: 14, height: 14)
                .padding(.top, 4)

            if !isLast {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
    }

    private func header(for entry: ChangelogEntry) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(entry.version.description)
                .font(.headline)
            Spacer(minLength: 8)
            if let date = entry.date {
                Text(date, format: .dateTime.month(.abbreviated).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func card(for entry: ChangelogEntry) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(entry.items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider().padding(.leading, 70)
                }
                ChangelogItemRow(item)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }
}

// MARK: - Collapsible

/// A compact overview: each version is a `DisclosureGroup` showing a one-line
/// summary (version, date, item count) until expanded. The latest version
/// starts expanded so the newest changes are visible on open.
struct CollapsibleHistoryLayout: View {

    let changelog: Changelog

    @State private var expanded: Set<AppVersion> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(changelog.entries) { entry in
                    disclosure(for: entry)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            if let latest = changelog.latest?.version {
                expanded.insert(latest)
            }
        }
    }

    // A hand-rolled disclosure rather than `DisclosureGroup`: tinting the
    // group's chevron would cascade into the rows and recolor the icon tiles,
    // which fall back to the ambient tint. Driving expansion ourselves keeps
    // the chevron secondary while the icons keep the app's tint.
    private func disclosure(for entry: ChangelogEntry) -> some View {
        let isExpanded = expanded.contains(entry.version)

        return VStack(spacing: 0) {
            Button {
                withAnimation(.snappy) {
                    if isExpanded { expanded.remove(entry.version) }
                    else { expanded.insert(entry.version) }
                }
            } label: {
                HStack(spacing: 8) {
                    summary(for: entry)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.forward")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(entry.items.enumerated()), id: \.element.id) { index, item in
                        if index > 0 {
                            Divider().padding(.leading, 70)
                        }
                        ChangelogItemRow(item)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private func summary(for entry: ChangelogEntry) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text("Version \(entry.version.description)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                if entry.version == changelog.latest?.version {
                    Text("LATEST")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(.systemBackground))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.accentColor, in: .capsule)
                }
            }
            Text(subtitle(for: entry))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func subtitle(for entry: ChangelogEntry) -> String {
        let count = entry.items.count
        let changes = "\(count) change\(count == 1 ? "" : "s")"
        guard let date = entry.date else { return changes }
        return "\(changes) · \(date.formatted(.dateTime.month(.abbreviated).year()))"
    }
}

// MARK: - Editorial

/// A magazine-style layout: a large display numeral for each version sits over
/// an accent rail, with the changes listed beside it. More expressive than the
/// grouped card, good for apps that want the history to feel like a story.
struct EditorialHistoryLayout: View {

    let changelog: Changelog

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                ForEach(changelog.entries) { entry in
                    section(for: entry)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func section(for entry: ChangelogEntry) -> some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(entry.version == changelog.latest?.version ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(.separator)))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 14) {
                header(for: entry)

                VStack(alignment: .leading, spacing: 20) {
                    ForEach(entry.items) { item in
                        ChangelogItemRow(item)
                    }
                }
            }
        }
    }

    private func header(for entry: ChangelogEntry) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(entry.version.description)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)

                if entry.version == changelog.latest?.version {
                    Text("LATEST")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tint)
                }
            }

            if let date = entry.date {
                Text(date, format: .dateTime.month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
