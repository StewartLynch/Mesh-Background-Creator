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
    @State private var showCode = false
    @State private var inspectorIsShown = true
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) var mode
    var body: some View {
        if let selectedObject = appState.selectedObject {
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
                    Toggle("Display Points", isOn: Bindable(appState).showPoints)
                    GeometryReader { geometry in
                        ZStack {
                            // Rectangle
                            
                            let points = selectedObject.meshPoints.flatMap { $0 }.map {$0.point}
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
                                    MeshGradient(
                                        width: selectedObject.width,
                                        height: selectedObject.height,
                                        points: sPoints,
                                        colors: colors
                                    )
                                    .shadow(color: selectedObject.withShadow ? selectedObject.shadow : .clear, radius: 25, x: -10, y: 10)
                                    .clipShape(RoundedRectangle(cornerRadius: 30 ))
                                }
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            
                            // Draggable Images
                            ForEach(0..<selectedObject.width, id: \.self) { col in
                                ForEach(0..<selectedObject.height, id: \.self) { row in
                                    PointView(
                                        index: row,
                                        selectedDevice: selectedDevice,
                                        size: geometry.size, symbol: selectedObject.meshPoints[row][col].symbol.rawValue,
                                        meshPoint: selectedObject.meshPoints[row][col].point
                                    )
                                    .opacity(appState.showPoints ? 1.0 : 0)
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
                    Button("Show Code") {
                        showCode.toggle()
                    }
                    .sheet(isPresented: $showCode) {
                        CodeView(code: selectedObject.code)
                    }
                })
                .inspector(isPresented: $inspectorIsShown) {
                    InspectorView(selectedObject: selectedObject)
                        .inspectorColumnWidth(min: 300, ideal: 300, max: 300)
                }
                .navigationTitle("Mesh Creator")
            }
        } else {
           Text("Pick it")
        }
    }
}

#Preview {
    MeshCreatorView()
        .environment(AppState(selectedObject: MeshObject.sample))
        .frame(
            width: 700, height: 600)
}

