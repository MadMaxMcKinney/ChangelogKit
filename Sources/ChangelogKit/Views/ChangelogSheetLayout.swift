import SwiftUI

/// The concrete layout backing both built-in changelog styles.
///
/// Renders the "What's New" title as a large navigation title, a scrolling
/// stack of ``ChangelogItemRow`` values, and a pinned bottom bar with a
/// prominent continue button and an optional "See Previous Updates" affordance.
///
/// `isCarded` boxes each entry on a grouped background for the
/// ``CardsChangelogSheetStyle``; otherwise it renders the ``grouped`` style's
/// clean list.
struct ChangelogSheetLayout: View {

    let configuration: ChangelogSheetStyleConfiguration
    var isCarded: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                items
            }
            .padding(.horizontal, isCarded ? 20 : 24)
            .padding(.top, 2)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        // Driving the title through the navigation bar gives the sheet's root a
        // defined bar state, so popping back from the pushed history view no
        // longer leaves that view's inline bar stranded on the sheet.
        .navigationTitle(configuration.title)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
    }

    @ViewBuilder
    private var header: some View {
        if let headline = configuration.entry.headline {
            Text(headline)
                .font(.headline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var items: some View {
        VStack(alignment: .leading, spacing: isCarded ? 14 : 16) {
            ForEach(configuration.entry.items) { item in
                ChangelogItemRow(item, isCarded: isCarded)
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            Button(action: configuration.onContinue) {
                configuration.continueLabel
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.glassProminent)

            if configuration.hasHistory {
                Button("See Previous Updates", action: configuration.onShowHistory)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.bar)
    }
}
