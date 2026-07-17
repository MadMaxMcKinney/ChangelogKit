import SwiftUI

/// The concrete layout backing both built-in changelog styles.
///
/// Renders a centered header, a scrolling stack of ``ChangelogItemRow`` values,
/// and a pinned bottom bar with a prominent continue button and an optional
/// "See Previous Updates" affordance.
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
            .padding(.top, 24)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            configuration.title
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            if let headline = configuration.entry.headline {
                Text(headline)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
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
