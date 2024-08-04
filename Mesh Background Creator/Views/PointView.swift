//
// ----------------------------------------------
// Original project: Mesh Background Creator
// by  Stewart Lynch on 2024-06-12
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

struct PointView: View {
    @Environment(AppState.self) var appState
    let index: Int
    let selectedDevice:Device
    let size: CGSize
    let symbol: String
    @Bindable var meshPoint: MPoint
    var body: some View {
        ColorPicker("\(index + 1)", selection: $meshPoint.color, supportsOpacity: true)
            .labelsHidden()
            .position(x: (meshPoint.xCoord * selectedDevice.width) + (size.width - selectedDevice.width) / 2,
                      y: (meshPoint.yCoord * selectedDevice.height) + (size.height - selectedDevice.height) / 2)
            .gesture(DragGesture()
                .onChanged { value in
                    let rectOriginX = (size.width - selectedDevice.width) / 2
                    let rectOriginY = (size.height - selectedDevice.height) / 2
                    
                    let newX = min(max(0, (value.location.x - rectOriginX) / selectedDevice.width), 1.0)
                    let newY = min(max(0, (value.location.y - rectOriginY) / selectedDevice.height), 1.0)
                    
                    meshPoint.xCoord = newX
                    meshPoint.yCoord = newY
                    appState.refreshView.toggle()
                }
            )
    }
}
