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

import Photos
import UniformTypeIdentifiers
struct MeshCreatorView: View {
    @State private var selectedDevice = Device.all.first!
    @State private var viewSize: CGSize = .zero
    @State private var inspectorIsShown = false
    @State var shareSheetItems: [Any] = []
    @State private var showShareSheet = false
    @Environment(AppState.self) private var appState
    @State private var background = Color.white
    @State private var saveAlert:ErrorAlert?
    @Environment(\.colorScheme) var colorScheme
    var isCompressed: Bool {
        viewSize.width < 400
    }
    
    enum ErrorAlert {
        case saveSuccess(String)
        case saveFail(String)
    }
    var body: some View {
        let selectedObject = appState.selectedObject
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
                        .padding()
                        .buttonStyle(.bordered)
                        Toggle("Show Points", isOn: Bindable(appState).showPoints)
                            .frame(width: 150)
                    }
                    .font(.callout)
                    
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
                .frame(width: max(viewSize.width / 2, 380))
                
                GeometryReader { geometry in
                    ZStack {
                        // Rectangle
                        RoundedRectangle(cornerRadius: 30 )
                            .stroke(Color.primary, lineWidth: 4)
                            .frame(width: selectedDevice.width, height: selectedDevice.height)
                            .overlay{
                                
                                MyGradientView(selectedObject: selectedObject, background: $background)
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
                }
#if os(macOS)
                Button("Save Image", systemImage: "photo.artframe") {
                    Task {
                        if let url = savePanel(for: .jpeg) {
                            save(with: .jpeg, at: url)
                        }
                    }
                }
#else
                Button {
                    if let image = MyGradientView(selectedObject: selectedObject, background: $background).renderedUIImage {
                        
                        saveImageToPhotos(image: image)
                    }
                } label: {
                    Image(systemName: "photo.artframe")
                }
                .alert("Desktop Image", isPresented: .constant(saveAlert != nil)) {
                    Button("OK") {
                        saveAlert = nil
                    }
                } message: {
                    switch saveAlert {
                    case .saveSuccess(let string):
                        Text(string)
                    case .saveFail(let string):
                        Text(string)
                    case nil:
                        Text("")
                    }
                }
                
                
#endif
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
#endif
                }
                
            }
        }
        .onChange(of: isCompressed) { oldValue, newValue in
            inspectorIsShown = !isCompressed
        }
        .onChange(of: colorScheme) { oldValue, newValue in
            background = colorScheme == .dark ? .black : .white
        }
        .onAppear {
            background = colorScheme == .dark ? .black : .white
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
        guard let cgImage = MyGradientView(selectedObject: appState.selectedObject, background: $background).renderedCGImage else { return }
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
#endif
    
#if os(iOS)
    func saveImageToPhotos(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    saveAlert = .saveSuccess("Successfully saved image to Photos.")
                    print("Successfully saved image to Photos.")
                } else if let error = error {
                    saveAlert = .saveFail("Error saving image to Photos: \(error.localizedDescription)")
                    print("Error saving image to Photos: \(error.localizedDescription)")
                }
            }
        }
    }
#endif
}

enum ContentType {
    case jpeg
    case png
}

#Preview {
    MeshCreatorView()
        .environment(AppState())
#if os(macOS)
        .frame(
            width: 700, height: 600)
#endif
}

