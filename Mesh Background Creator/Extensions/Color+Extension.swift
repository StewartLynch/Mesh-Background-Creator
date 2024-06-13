//
// ----------------------------------------------
// Original project: Mesh Background Creator
// by  Stewart Lynch on 2024-06-13
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

//#if os(macOS)
extension Color {
    init(platformColor: PlatformColor) {
            #if os(iOS)
            let components = platformColor.cgColor.components!
            let red = Double(components[0])
            let green = Double(components[1])
            let blue = Double(components[2])
            let alpha = Double(components[3])
            #elseif os(macOS)
            let red = platformColor.redComponent
            let green = platformColor.greenComponent
            let blue = platformColor.blueComponent
            let alpha = platformColor.alphaComponent
            #endif
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        }
    private func toPlatformColor() -> PlatformColor {
            #if os(macOS)
            let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
            var hexNumber: UInt64 = 0
            scanner.scanHexInt64(&hexNumber)
            
            let r, g, b, a: CGFloat
            switch self.description.count {
            case 9:
                r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000FF) / 255
            case 7:
                r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000FF) / 255
                a = 1.0
            default:
                r = 0
                g = 0
                b = 0
                a = 1.0
            }
            
            return NSColor(red: r, green: g, blue: b, alpha: a)
            #else
            return UIColor(self)
            #endif
        }
        
        // Convert platform-specific color (NSColor or UIColor) to Hex String
        func toHex() -> String? {
            let platformColor = toPlatformColor()
            
            #if os(macOS)
            guard let components = platformColor.cgColor.components, components.count >= 3 else {
                return nil
            }
            #else
            guard let components = platformColor.cgColor?.components, components.count >= 3 else {
                return nil
            }
            #endif
            
            let r = Float(components[0])
            let g = Float(components[1])
            let b = Float(components[2])
            let a = Float(components.count >= 4 ? components[3] : 1.0)
            
            let hexString = String(format: "%02X%02X%02X%02X",
                                   Int(r * 255),
                                   Int(g * 255),
                                   Int(b * 255),
                                   Int(a * 255))
            return hexString
        }
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
