//
// ----------------------------------------------
// Original project: Mesh Background Creator
// by  Stewart Lynch on 2024-06-14
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

struct Menus: Commands {
    @Environment(AppState.self) var appState
    var body: some Commands {
        SidebarCommands()
        ToolbarCommands()
        CommandGroup(replacing: .help) {
            Link(destination: URL(string: "https://bento.me/StewartLynch")!) {
                Text("Contact...")
            }
            Link(destination: URL(string: "https://youtube.com/@StewartLynch")!) {
                Text("Subscribe to Channel...")
            }
        }
        CommandGroup(after: .newItem) {
            Divider()
            Button("Export as Desktop Image...") {
                appState.export = true
            }
            .keyboardShortcut("e", modifiers: [.command])
        }
        CommandGroup(after: .undoRedo) {
            Divider()
            Button("Copy code to clipboard...") {
                appState.showCode.toggle()
            }
            .keyboardShortcut("m", modifiers: [.command, .shift])
        }
    }
    
}
