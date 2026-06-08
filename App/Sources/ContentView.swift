import Counter
import SwiftUI
import UIComponents

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Badge(text: "Sample Native Bazel App")
                .foregroundStyle(Theme.accent)
            CounterView()
            #if LIMRUN
            Text("LIMRUN preview build")
                .font(.footnote)
                .foregroundStyle(.secondary)
            #endif
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
