

//
// Created for StewartLynchYT
// by  Stewart Lynch on 2024-04-07
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI
//#if os(macOS)
extension Color {
    var luminance: Double {
        // Convert SwiftUI Color to NSColor
        guard let nsColor = NSColor(color: self) else {
            return 0.0 // Default luminance value if conversion fails
        }
        
        // Convert the color to RGB space if possible
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return 0.0 // Default luminance value if conversion fails
        }

        // Extract RGB values
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        // Compute luminance
        return 0.2126 * Double(red) + 0.7152 * Double(green) + 0.0722 * Double(blue)
    }
   
    var adaptedTextColor: Color {
        luminance > 0.5 ? Color.black : Color.white
    }
}

extension NSColor {
    convenience init?(color: Color) {
        guard let cgColor = color.cgColor else { return nil }
        self.init(cgColor: cgColor)
    }
}

