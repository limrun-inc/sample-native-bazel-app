import SwiftUI

/// A simple rounded badge used across the app.
public struct Badge: View {
    private let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.accent.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}
