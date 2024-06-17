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
#if os(macOS)
import AppKit
#else
import UIKit
#endif

import UniformTypeIdentifiers
struct MeshCreatorView: View {
    @State private var selectedDevice = Device.all.first!
    @State private var viewSize: CGSize = .zero
    @State private var inspectorIsShown = false
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) var mode
    var isCompressed: Bool {
        viewSize.width < 400
    }
    var body: some View {
        if let selectedObject = appState.selectedObject {
            NavigationStack {
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Menu(selectedDevice.name) {
                                ForEach(isCompressed ? Device.iPhone : Device.all) { device in
                                    Button(device.name) {
                                        withAnimation {
                                            selectedDevice = device
                                        }
                                    }
                                }
                            }
                            .frame(width: 150)
                            .padding()
                            .buttonStyle(.bordered)
                            Toggle("Show Points", isOn: Bindable(appState).showPoints)
                                .frame(width: 150)
                                .font(.callout)
                        }
                        
                        if selectedDevice.name == "Custom" {
                            GroupBox {
                                LabeledContent("Width:") {
                                    Slider(value: $selectedDevice.width, in: 100...viewSize.width - 20)
                                }
                                LabeledContent("Height:") {
                                    Slider(value: $selectedDevice.height, in: 100...viewSize.height - 20)
                                }
                            }
                        }
                        Spacer()
                    }
                    
                   

                    GeometryReader { geometry in
                        ZStack {
                            // Rectangle
                            RoundedRectangle(cornerRadius: 30 )
                                .stroke(Color.primary, lineWidth: 4)
                                .frame(width: selectedDevice.width, height: selectedDevice.height)
                                .overlay{
                                    MyGradientView(selectedObject: selectedObject)
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
                        .readSize {
                            viewSize = $0
                        }
                    }
                }
                .toolbar(content: {
                    Button("Get Code", systemImage: "doc.text") {
                        appState.showCode.toggle()
                    }
                    .sheet(isPresented: Bindable(appState).showCode) {
                        CodeView(code: selectedObject.code)
                        Button("Save Image", systemImage: "square.and.arrow.down") {
                            Task {
                    }
#if os(macOS)
                            if let url = savePanel(for: .jpeg) {
                                save(with: .jpeg, at: url)
                            }
#else
#endif
                        }
                    }
                    Button {
                        inspectorIsShown.toggle()
                    } label: {
                        Label(inspectorIsShown ? "Hide Inspector" : "Show Inspector", systemImage: isCompressed ? "gear" : "sidebar.trailing")
                    }
                })
                .inspector(isPresented: $inspectorIsShown) {
                    InspectorView(selectedObject: selectedObject)
                        .inspectorColumnWidth(min: 300, ideal: 300, max: 300)
                }
                .navigationTitle("Mesh Creator")
            }
            .onChange(of: appState.export) { _, newValue in
                if newValue {
                    appState.export = false
                    Task {
#if os(macOS)
                        if let url = savePanel(for: .jpeg) {
                            save(with: .jpeg, at: url)
                        }
#else
#endif
                    }

                }
            }
            .onChange(of: isCompressed) { oldValue, newValue in
                inspectorIsShown = !isCompressed
            }
        } else {
            Text("Pick it")
        }
    }
    
#if os(macOS)
    private func savePanel(for type: UTType) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [type]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save the MeshGradient as a Desktop image"
        savePanel.message = "Choose a folder and a name to store the image."
        savePanel.nameFieldLabel = "Image file name:"

        return savePanel.runModal() == .OK ? savePanel.url : nil
    }
    
    @MainActor func save(with contentType: ContentType, at url: URL) {
        let desktopView = MyGradientView(selectedObject: appState.selectedObject!).frame(width: 1920, height: 1080)
        guard let cgImage = ImageRenderer(content: desktopView).cgImage else {
            return
        }

        let image = NSImage(cgImage: cgImage, size: .init(width: 1920, height: 1080))
        guard let representation = image.tiffRepresentation else { return }
        let imageRepresentation = NSBitmapImageRep(data: representation)

        let imageData: Data?
        switch contentType {
        case .jpeg: imageData = imageRepresentation?.representation(using: .jpeg, properties: [:])
        case .png: imageData = imageRepresentation?.representation(using: .png, properties: [:])
        }

        try? imageData?.write(to: url)
    }
#else
    
#endif
}

enum ContentType {
    case jpeg
    case png
}

struct MyGradientView: View {
    let selectedObject: MeshObject
    var body: some View {
        let points = selectedObject.meshPoints.flatMap { $0 }.map {$0.point}
        let sPoints:[SIMD2<Float>] = points.map { point in
                .init(Float(point.xCoord), Float(point.yCoord))
        }
        let colors: [Color] = points.map { point in
            point.color
        }
        MeshGradient(
            width: selectedObject.width,
            height: selectedObject.height,
            points: sPoints,
            colors: colors,
            background: selectedObject.withBackground ? selectedObject.backgroundColor : .clear,
            smoothsColors: selectedObject.smoothColors
        )
        .shadow(color: selectedObject.withShadow ? selectedObject.shadow : .clear, radius: 25, x: -10, y: 10)
    }
}
#Preview {
    MeshCreatorView()
        .environment(AppState(selectedObject: MeshObject.sample))
#if os(macOS)
        .frame(
            width: 700, height: 600)
#endif
}

