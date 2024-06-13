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
    var body: some View {
        Text(appState.selectedObject.name)
        .padding()
        GroupBox {
            Toggle("Show Shadow", isOn: Bindable(appState).selectedObject.withShadow)
            ColorPicker("Dark Shadow", selection: Bindable(appState).selectedObject.darkShadow)
            ColorPicker("Light Shadow", selection: Bindable(appState).selectedObject.lightShadow)
        }
        .padding()
        
        
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

