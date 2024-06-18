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
    var desktopView: some View {
        self.frame(width: 1920, height: 1080)
    }
#if os(macOS)
    var renderedCGImage: CGImage? {
        return ImageRenderer(content: desktopView).cgImage
    }
#else
    var renderedImage: Image? {
        let renderer = ImageRenderer(content: desktopView)
        renderer.scale = 3
        if let image = renderer.cgImage {
            return Image(decorative: image, scale: 1.0)
        } else {
            return nil
        }
    }
    
    var renderedUIImage: UIImage? {
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
