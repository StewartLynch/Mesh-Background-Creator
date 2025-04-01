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

struct InspectorView: View {
    @Environment(AppState.self) private var appState
    @Bindable var selectedObject: MeshObject
    @State private var width:Int = 1
    @State private var height: Int = 1
    @State private var renderedImage: Image?
    var body: some View {
        VStack(alignment: .leading) {
            Text("Configuration")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
            GroupBox {
                Group {
                    LabeledContent("Width:") {
                        Menu("\(width)") {
                            ForEach(2..<10) { index in
                                Button("\(index)") {
                                    if index != selectedObject.width {
                                        appState.tempObject = selectedObject
                                        let newObject = MeshObject(name: selectedObject.name, width: index, height: selectedObject.height, meshPoints: [])
                                        newObject.meshPoints = newObject.generateSampleMeshPoints()
                                        appState.selectedObject = newObject
                                        width = index
                                    }
                                }
                            }
                        }
                    }
                    LabeledContent("Height") {
                        Menu("\(height)") {
                            ForEach(2..<10) { index in
                                Button("\(index)") {
                                    if index != selectedObject.height {
                                        appState.tempObject = selectedObject
                                        let newObject = MeshObject(name: selectedObject.name, width: selectedObject.width, height: index, meshPoints: [])
                                        newObject.meshPoints = newObject.generateSampleMeshPoints()
                                        appState.selectedObject = newObject
                                        height = index
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(width: 100, alignment: .center)
                if !selectedObject.withShadow {
                    Toggle("With Background", isOn: $selectedObject.withBackground)
                    if selectedObject.withBackground {
                        ColorPicker("Color", selection: $selectedObject.backgroundColor)
                    }
                }
                if !selectedObject.withBackground {
                    Toggle("Show Shadow", isOn: $selectedObject.withShadow)
                    if selectedObject.withShadow {
                        ColorPicker("Color", selection: $selectedObject.shadow)
                    }
                }
                Toggle("Smooth Colors", isOn: $selectedObject.smoothColors)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            if selectedObject.meshPoints.count > 0 {
                List(0..<selectedObject.height, id: \.self) { row in
                    ForEach(0..<selectedObject.width, id: \.self) { col in
                        let point = selectedObject.meshPoints[row][col].point
                        let symbol = selectedObject.meshPoints[row][col].symbol
                        let color = selectedObject.meshPoints[row][col].point.color
                        VStack {
                            HStack {
                                Image(systemName: "\(symbol)")
                                    .font(.title)
                                    .foregroundStyle(color)
                                    .overlay {
                                        Text("\(row + 1)")
                                            .font(.body)
                                    }
                                Text("(\(String(format: "%.2f", point.xCoord)), \(String(format: "%.2f", point.yCoord)))")
                                
                                ColorPicker("", selection: $selectedObject.meshPoints[row][col].point.color)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    Divider()
                }
#if os(iOS)
                .listStyle(.plain)
#endif
            }
        }
        .onAppear {
            width = selectedObject.width
            height = selectedObject.height
        }
    }
}


