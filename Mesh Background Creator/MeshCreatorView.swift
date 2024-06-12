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

@Observable
class MeshObject: Identifiable {
    /*
     MeshGradient(width: 3, height: 3, points: [
         .init(0, 0), .init(0.5, 0), .init(1, 0),
         .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
         .init(0, 1), .init(0.5, 1), .init(1, 1)
     ], colors: [
         .red, .purple, .indigo,
         .orange, .white, .blue,
         .yellow, .green, .mint
     ])
     */
    let id = UUID()
    let name: String
    let width: Int
    let height: Int
    var meshPoint: MeshPoint
    
    init(name: String, width: Int, height: Int, meshPoint: MeshPoint) {
        self.name = name
        self.width = width
        self.height = height
        self.meshPoint = meshPoint
    }
    
    static var sample:MeshObject {
        .init(
            name: "First",
            width: 3,
            height: 3,
            meshPoint: .init(
                points: [
                    .init(xCoord: 0, yCoord: 0), .init(xCoord: 0.5, yCoord: 0), .init(xCoord: 1, yCoord: 0),
                    .init(xCoord: 0, yCoord: 0.5), .init(xCoord: 0.5, yCoord: 0.5), .init(xCoord: 1, yCoord: 0.5),
                    .init(xCoord: 0, yCoord: 1), .init(xCoord: 0.5, yCoord: 1), .init(xCoord: 1, yCoord: 1),
                ],
                colors: [.red, .purple, .indigo,
                         .orange, .white, .blue,
                         .yellow, .green, .mint]
            )
        )
    }
    
}


struct MeshPoint {
    var points: [MPoint]
    var colors: [Color]
}

struct MPoint: Identifiable {
    var id = UUID()
    var xCoord: CGFloat
    var yCoord: CGFloat
    let dragOffset = CGSize.zero
}


import SwiftUI
import AppKit

extension NSColor {
    static var random: NSColor {
        let red = CGFloat.random(in: 0...1)
            let green = CGFloat.random(in: 0...1)
            let blue = CGFloat.random(in: 0...1)
            return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}

struct MeshCreatorView: View {
    @State private var selectedDevice = Device.all.first!
    @State private var inspectorIsShown = true
    @Environment(AppState.self) private var appState
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
                        RoundedRectangle(cornerRadius: 30 )
                            .stroke(Color.primary, lineWidth: 4)
                            .frame(width: selectedDevice.width, height: selectedDevice.height)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        // Draggable Images
                        ForEach(0..<appState.selectedObject.meshPoint.points.count, id: \.self) { index in
                            PointView(
                                index: index,
                                selectedDevice: selectedDevice,
                                size: geometry.size,
                                meshPoint: Bindable(appState).selectedObject.meshPoint.points[index]
                            )
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


struct PointView: View {
    let index: Int
    let selectedDevice:Device
    let size: CGSize
    @Binding var meshPoint: MPoint
    var body: some View {
        Image(systemName: "\(index + 1).circle.fill")
            .font(.title2)
            .foregroundColor(.blue)
            .background(Color.white)
            .clipShape(.circle)
            .frame(width: 20, height: 20)
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
                }
            )
    }
}


struct InspectorView: View {
    @Environment(AppState.self) private var appState
    var body: some View {
        Form {
            ForEach(0..<appState.selectedObject.meshPoint.points.count, id:\.self) { index in
                let point = appState.selectedObject.meshPoint.points[index]
                VStack {
                    HStack {
                        Image(systemName: "\(index + 1).circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(.circle)
                        Text("(\(String(format: "%.2f", point.xCoord)), \(String(format: "%.2f", point.yCoord)))")
                        Spacer()
                        ColorPicker("", selection: Bindable(appState).selectedObject.meshPoint.colors[index])
                    }
                }
                    
            }
        }
       
    }
}
