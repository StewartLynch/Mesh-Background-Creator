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

struct TestView: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    @State private var xCoord: CGFloat = 0.5
    @State private var yCoord: CGFloat = 0.5
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        HStack {
            // Left Pane
            GeometryReader { geometry in
//                let maxWidth = geometry.size.width
//                let maxHeight = geometry.size.height
//                
                ZStack {
                    // Rectangle
                    Rectangle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: self.width, height: self.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    
                    // Draggable Image
                    Image(systemName: "circle.fill")
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20)
                        .position(x: (xCoord * width) + (geometry.size.width - width) / 2,
                                  y: (yCoord * height) + (geometry.size.height - height) / 2)
                        .gesture(DragGesture()
                            .onChanged { value in
                                let rectOriginX = (geometry.size.width - self.width) / 2
                                let rectOriginY = (geometry.size.height - self.height) / 2
                                
                                let newX = min(max(0, (value.location.x - rectOriginX) / self.width), 1.0)
                                let newY = min(max(0, (value.location.y - rectOriginY) / self.height), 1.0)
                                
                                self.xCoord = newX
                                self.yCoord = newY
                            }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Divider()
            
            // Right Pane
            VStack {
                // Width Slider
                VStack {
                    Slider(value: $width, in: 0...500, step: 1)
                    Text("Width: \(Int(width))")
                }
                .padding()
                
                // Height Slider
                VStack {
                    Slider(value: $height, in: 0...500, step: 1)
                    Text("Height: \(Int(height))")
                }
                .padding()
                
                // Button to Plot Image
                Button(action: {
                    // Re-position the image based on the new coordinates
                    self.dragOffset = .zero
                }) {
                    Text("Plot Image")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                Text("(\(String(format: "%.2f", xCoord)), \(String(format: "%.2f", yCoord)))")
                    .foregroundStyle(.black)
                    .background(Color.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    TestView()
}
