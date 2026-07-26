import SwiftUI

/// A changelog item's symbol rendered as an app-icon-style tile: a tinted,
/// continuously-rounded square "frame" with the SF Symbol centered inside.
///
/// Shared by ``ChangelogItemRow`` and the built-in item detail layouts so an
/// entry's icon looks identical at every size. Sizing scales with Dynamic Type
/// through the caller's `size`.
///
/// Public so a custom ``ChangelogSheetStyle`` or ``ChangelogItemDetailStyle`` can
/// build its own header without reimplementing the tile.
public struct ChangelogItemIcon: View {

    /// The SF Symbol drawn inside the tile.
    let symbol: String

    /// A per-item accent. Falls back to the environment tint when `nil`.
    let tint: Color?

    /// The tile's edge length in points.
    var size: CGFloat = 52

    /// Creates an icon tile.
    /// - Parameters:
    ///   - symbol: The SF Symbol drawn inside the tile.
    ///   - tint: A per-item accent. Falls back to the environment tint when `nil`.
    ///   - size: The tile's edge length in points.
    public init(symbol: String, tint: Color? = nil, size: CGFloat = 52) {
        self.symbol = symbol
        self.tint = tint
        self.size = size
    }

    /// The squircle corner radius, a touch rounder than a system app icon.
    private var cornerRadius: CGFloat { size * 0.26 }

    /// The fill for the tile: an item tint, or the environment tint.
    private var fill: AnyShapeStyle {
        tint.map(AnyShapeStyle.init) ?? AnyShapeStyle(.tint)
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fill)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: size * 0.46, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
    }
}

#Preview("Icons", traits: .sizeThatFitsLayout) {
    HStack(spacing: 16) {
        ChangelogItemIcon(symbol: "map", tint: .blue)
        ChangelogItemIcon(symbol: "sparkles", tint: .purple, size: 72)
        ChangelogItemIcon(symbol: "lock.shield", tint: nil, size: 44)
    }
    .padding()
    .tint(.indigo)
}
