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


import Foundation

@Observable
class Device: Identifiable {
    let id = UUID()
    var width: CGFloat
    var height: CGFloat
    let name: String
    
    init(width: CGFloat, height: CGFloat, name: String) {
        self.width = width
        self.height = height
        self.name = name
    }
    
    static var all: [Device] {
       [
        Device(width: 219, height: 445, name: "iPhone 6.1\""),
        Device(width: 237, height: 485, name: "iPhone 6.7\""),
        Device(width: 566.5, height: 372, name: "iPad 11\""), //2266 X 1488
        Device(width: 683, height: 512, name: "iPad 13\""),  //2732 X 2048
        Device(width: 200, height: 400, name: "Custom")  //2732 X 2048
        ]
    }
    
    static var iPhone: [Device] {
        [
         Device(width: 219, height: 445, name: "iPhone 6.1\""),
         Device(width: 237, height: 485, name: "iPhone 6.7\""),
         Device(width: 350, height: 200, name: "Custom")  //2732 X 2048
         ]
    }
}

