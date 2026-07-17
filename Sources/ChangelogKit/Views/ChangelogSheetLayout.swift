import SwiftUI

/// The concrete layout backing both built-in changelog styles.
///
/// Renders a centered header, a scrolling list of ``ChangelogItemRow`` values,
/// and a pinned bottom bar with a prominent continue button and an optional
/// "See Previous Updates" affordance. `isProminent` scales up the header for
/// the ``ProminentChangelogSheetStyle``.
struct ChangelogSheetLayout: View {

    let configuration: ChangelogSheetStyleConfiguration
    let isProminent: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                items
            }
            .padding(.horizontal, 24)
            .padding(.top, isProminent ? 40 : 24)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            configuration.title
                .font(isProminent ? .largeTitle.weight(.heavy) : .largeTitle.bold())
                .multilineTextAlignment(.center)

            if let headline = configuration.entry.headline {
                Text(headline)
                    .font(isProminent ? .title3 : .headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private var items: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(configuration.entry.items) { item in
                ChangelogItemRow(item)
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
