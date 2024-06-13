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

@main
struct Mesh_Background_CreatorApp: App {
    @State private var appState = AppState(selectedObject: MeshObject.sample)
    var body: some Scene {
        WindowGroup {
            MeshCreatorView()
                .frame(
                  minWidth: 800,
                  idealWidth: 800,
                  maxWidth: .infinity,
                  minHeight: 600,
                  idealHeight: 600,
                  maxHeight: .infinity)
                .environment(appState)
        }
    }
}
