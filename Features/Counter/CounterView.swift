import StringUtils
import SwiftUI
import UIComponents

/// A small interactive feature module. The caption demonstrates Swift/ObjC
/// interop by running text through the Objective-C `StringUtils` helper.
public struct CounterView: View {
    @State private var count = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Text("Count: \(count)")
                .monospacedDigit()
            Button("Increment") {
                count += 1
            }
            .tint(Theme.accent)
            Text("ObjC reverse(\"Limrun\") = \(StringUtils.reverse("Limrun"))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Theme.accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

#Preview {
    CounterView()
}
