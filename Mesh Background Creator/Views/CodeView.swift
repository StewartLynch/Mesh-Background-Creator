//
// ----------------------------------------------
// Original project: Mesh Background Creator
// by  Stewart Lynch on 2024-06-13
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

struct CodeView: View {
    @Environment(\.dismiss) var dismiss
    let code: String
    var body: some View {
        NavigationStack {
            ScrollView{
                Text(code)
            }
            .contentMargins(50, for: .scrollContent)
                .navigationTitle("Code")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
    #if os(macOS)
                            let pasteboard = NSPasteboard.general
                            pasteboard.declareTypes([.string], owner: nil)
                            pasteboard.setString(code, forType: .string)
    #else
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = code
    #endif
                            dismiss()
                        } label: {
                            Image(systemName: "doc.on.doc.fill")
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    CodeView(code: "")
}
