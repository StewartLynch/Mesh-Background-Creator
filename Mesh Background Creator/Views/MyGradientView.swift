//
// ----------------------------------------------
// Original project: Mesh Background Creator
// by  Stewart Lynch on 2024-06-18
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

struct MyGradientView: View {
    @Bindable var selectedObject: MeshObject
    @Binding var background: Color
    
#if os(macOS)
    var renderedCGImage: CGImage? {
        let desktopView = self.frame(width: 1920, height: 1080).background(background)
        return ImageRenderer(content: desktopView).cgImage
    }
#else
    var renderedUIImage: UIImage? {
        let desktopView =  self.frame(width: 1920, height: 1080).background(background)
        let renderer = ImageRenderer(content: desktopView)
        renderer.scale = 3
        if let image = renderer.cgImage {
            return UIImage(cgImage: image)
        } else {
            return nil
        }
    }
#endif
    var body: some View {
        var points: [MPoint] {
            selectedObject.meshPoints.flatMap { $0 }.map {$0.point}
        }
        var sPoints:[SIMD2<Float>]  { points.map { point in
                .init(Float(point.xCoord), Float(point.yCoord))
        }
        }
        var colors: [Color] { points.map { point in
            point.color
        }
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
    MyGradientView(selectedObject: MeshObject.sample, background: .constant(.white))
    
}
