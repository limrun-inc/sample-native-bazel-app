import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, from Bazel!")
            #if LIMRUN
            Text("LIMRUN preview build")
            #endif
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
