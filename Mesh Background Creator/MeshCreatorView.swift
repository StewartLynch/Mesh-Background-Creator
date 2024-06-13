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
import AppKit

struct MeshCreatorView: View {
    @State private var selectedDevice = Device.all.first!
    @State private var inspectorIsShown = true
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) var mode
    var body: some View {
        NavigationStack {
            VStack {
                Menu(selectedDevice.name) {
                    ForEach(Device.all) { device in
                        Button(device.name) {
                            selectedDevice = device
                        }
                    }
                }
                .frame(width: 200)
                .padding()
                GeometryReader { geometry in
                    ZStack {
                        // Rectangle
                        let object = appState.selectedObject
                        let points = appState.selectedObject.meshPoints.flatMap { $0 }.map {$0.point}
                        let sPoints:[SIMD2<Float>] = points.map { point in
                                .init(Float(point.xCoord), Float(point.yCoord))
                        }
                        let colors: [Color] = points.map { point in
                            point.color
                        }
                        RoundedRectangle(cornerRadius: 30 )
                            .stroke(Color.primary, lineWidth: 4)
                            .frame(width: selectedDevice.width, height: selectedDevice.height)
                            .overlay{
                                var shadowColor:Color {
                                    if appState.selectedObject.withShadow {
                                        if mode == .dark {
                                            return appState.selectedObject.darkShadow
                                        } else {
                                            return appState.selectedObject.lightShadow
                                        }
                                    } else {
                                        return Color.clear
                                    }
                                }
                                MeshGradient(
                                    width: object.width,
                                    height: object.height,
                                    points: sPoints,
                                    colors: colors
                                )
                                .shadow(color: shadowColor, radius: 25, x: -10, y: 10)
                                .clipShape(RoundedRectangle(cornerRadius: 30 ))
                            }
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                        // Draggable Images
                        ForEach(0..<appState.selectedObject.width, id: \.self) { col in
                            ForEach(0..<appState.selectedObject.height, id: \.self) { row in
                                PointView(
                                    index: row,
                                    selectedDevice: selectedDevice,
                                    size: geometry.size, symbol: appState.selectedObject.meshPoints[col][row].symbol.rawValue,
                                    meshPoint: Bindable(appState).selectedObject.meshPoints[col][row].point
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
            }
            .toolbar(content: {
                Button {
                    inspectorIsShown.toggle()
                } label: {
                    Label("Show Inspector", systemImage: "sidebar.trailing")
                }
            })
            .inspector(isPresented: $inspectorIsShown) {
                InspectorView()
                    .inspectorColumnWidth(min: 300, ideal: 300, max: 300)
            }
            .navigationTitle("Mesh Creator")
        }
    }
}

#Preview {
    MeshCreatorView()
        .environment(AppState(selectedObject: MeshObject.sample))
}
