import SwiftUI

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello from Limrun!")
            Button("Count: \(count)") {
                count += 1
            }
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
