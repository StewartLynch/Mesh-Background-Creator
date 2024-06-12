//
// ----------------------------------------------
// Original project: Mesh Background Creator
// by  Stewart Lynch on 2024-06-11
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
// ----------------------------------------------
// Copyright © 2024 CreaTECH Solutions. All rights reserved.


import SwiftUI

struct ContentView: View {
    @State private var inspectorIsShown = false
    var body: some View {
        NavigationStack {
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0.5, 1.0), .init(0.7, 0.5), .init(1, 0.7),
                .init(0, 1), .init(0, 0.5), .init(0, 0.5)
            ], colors: [
                .teal, .purple, .indigo,
                .purple, .blue, .pink,
                .purple, .red, .purple
            ])
            .toolbar(content: {
            Button(action: {
            inspectorIsShown.toggle()
            }, label: {
            Label("Show Inspector", systemImage: "sidebar.trailing")
            })
            })
            .inspector(isPresented: $inspectorIsShown) {
                Text("Inspector")
                    .inspectorColumnWidth(min: 200, ideal: 400, max: 600)
            }
            .navigationTitle("Mesh Creator")
        
        }
        .frame(width: 400, height: 800)
    }
}

#Preview {
    ContentView()
}
