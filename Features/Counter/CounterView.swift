import StringUtils
import SwiftUI
import UIComponents

/// A small interactive feature module: a counter whose label is run through
/// the Objective-C `StringUtils` helper to exercise Swift/ObjC interop.
public struct CounterView: View {
    @State private var count = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Text(StringUtils.reverse("Count: \(count)"))
                .monospacedDigit()
            Button("Increment") {
                count += 1
            }
            .tint(Theme.accent)
        }
        .padding()
        .background(Theme.accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

#Preview {
    CounterView()
}
