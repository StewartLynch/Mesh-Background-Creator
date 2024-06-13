//
// ----------------------------------------------
// Original project: ColorExtensionTesting-2
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


#if os(macOS)
import AppKit
typealias PlatformColor = NSColor
#else
import UIKit
typealias PlatformColor = UIColor
#endif

extension PlatformColor {
    // Initializes a new UIColor or NSColor instance from a hex string
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        let scanner = Scanner(string: hexString)
        var rgbValue: UInt64 = 0
        guard scanner.scanHexInt64(&rgbValue) else {
            return nil
        }

        var red, green, blue, alpha: UInt64
        switch hexString.count {
        case 6:
            red = (rgbValue >> 16) & 0xFF
            green = (rgbValue >> 8) & 0xFF
            blue = rgbValue & 0xFF
            alpha = 255
        case 8:
            red = (rgbValue >> 16) & 0xFF
            green = (rgbValue >> 8) & 0xFF
            blue = rgbValue & 0xFF
            alpha = (rgbValue >> 24) & 0xFF
        default:
            return nil
        }

        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
    }

    // Returns a hex string representation of the UIColor or NSColor instance
    func toHexString(includeAlpha: Bool = false) -> String? {
        // Get the red, green, and blue components of the UIColor or NSColor as floats between 0 and 1
        guard let components = self.cgColor.components else {
            return nil
        }

        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)
        let alpha = components.count > 3 ? Int(components[3] * 255.0) : 255

        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", alpha, red, green, blue)
        } else {
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }
    
    // Calculate luminance of the color
    func luminance() -> CGFloat {
        guard let components = self.cgColor.components else {
            return 0
        }

        let red = components[0]
        let green = components[1]
        let blue = components[2]

        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
    
    // Computed property to get adapted text color based on luminance
    var adaptedTextColor: PlatformColor {
        return luminance() > 0.5 ? PlatformColor.black : PlatformColor.white
    }

}
