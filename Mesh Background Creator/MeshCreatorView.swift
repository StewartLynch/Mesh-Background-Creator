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
    static var colors: [Color] {
        [
            .red, .purple, .indigo,
            .orange, .white, .blue,
            .yellow, .green, .mint,
            .teal, .red, .indigo
        ]
    }
    
    enum Symbol: String, CaseIterable {
        case circle
        case square
        case triangle
        case diamond
        case star
        case hexagon
    }
    
    static var pointColors: [Color] {
        [
            .blue,
            .red,
            .green,
            .orange,
            .teal
        ]
    }

    let id = UUID()
    let name: String
    let width: Int
    let height: Int
    var meshPoints: [[MeshPoint]]
    
    init(name: String, width: Int, height: Int, meshPoints: [[MeshPoint]]) {
        self.name = name
        self.width = width
        self.height = height
        self.meshPoints = meshPoints
    }
    
    func generateSampleMeshPoints() -> [[MeshPoint]] {
        var rowBreaks: [CGFloat] {
            var rowBreaks: [CGFloat] = []
            (0...height-1).forEach { index in
                rowBreaks.append(CGFloat(index) / CGFloat(height-1))
            }
            return rowBreaks
        }
        var colBreaks: [CGFloat] {
            var colBreaks: [CGFloat] = []
            (0...width-1).forEach { index in
                colBreaks.append(CGFloat(index) / CGFloat(width-1))
            }
            return colBreaks
        }
        var allPoints: [[MeshPoint]] = []
        var symbols = MeshObject.Symbol.allCases
        (0..<height).forEach { row in
            let symbol = symbols.first
            var points: [MeshPoint] = []
            (0..<width).forEach { col in
                let newPoint = MeshPoint(
                    row: row,
                    col: col,
                    point: .init(
                        xCoord: colBreaks[col],
                        yCoord: rowBreaks[row],
                        color: MeshObject.colors.randomElement()!
                    ),
                    symbol: symbol!
                )
                points.append(newPoint)
            }
            symbols.removeFirst()
            allPoints.append(points)
        }

        return allPoints
    }
           
    static var sample: MeshObject {
        let newMeshObject = MeshObject(name: "Sample", width: 3, height: 3, meshPoints: [])
        let points = newMeshObject.generateSampleMeshPoints()
        newMeshObject.meshPoints = points
        return newMeshObject
    }
    
}


struct MeshPoint {
    var row: Int
    var col: Int
    var point: MPoint
    var symbol: MeshObject.Symbol
}

struct MPoint: Identifiable {
    var id = UUID()
    var xCoord: CGFloat
    var yCoord: CGFloat
    let dragOffset = CGSize.zero
    var color: Color
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
                        let object = appState.selectedObject
                        var points = appState.selectedObject.meshPoints.flatMap { $0 }.map {$0.point}
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
                                    width: object.width,
                                    height: object.height,
                                    points: sPoints,
                                    colors: colors
                                )
                                .shadow(color: .cyan, radius: 25, x: -10, y: 10)
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


struct PointView: View {
    let index: Int
    let selectedDevice:Device
    let size: CGSize
    let symbol: String
    @Binding var meshPoint: MPoint
    var body: some View {
//        Image(systemName: "\(index + 1).circle.fill")
        Image(systemName: "\(symbol).fill")
            .font(.title)
            .foregroundStyle(meshPoint.color)
            .overlay {
                Text("\(index + 1)")
                    .font(.body)
                    .foregroundStyle(meshPoint.color.adaptedTextColor)
            }
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
        Text(appState.selectedObject.name)
        VStack {
            ForEach(0..<appState.selectedObject.width, id: \.self) { col in
                ForEach(0..<appState.selectedObject.height, id: \.self) { row in
                    let point = appState.selectedObject.meshPoints[col][row].point
                    let symbol = appState.selectedObject.meshPoints[col][row].symbol
                    let color = appState.selectedObject.meshPoints[col][row].point.color
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
                            
                            ColorPicker("", selection: Bindable(appState).selectedObject.meshPoints[col][row].point.color)
                        }
                    }
                }
                Divider()
            }
        }
       
    }
}
