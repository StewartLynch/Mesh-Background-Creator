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

@Observable
class MeshObject: Identifiable {
    static var colors: [Color] {
        [
            .red, .purple, .indigo,
            .orange, .white, .blue,
            .yellow, .green, .mint,
            .teal, .red, .indigo
        ]
    }
    
    enum Symbol: String, CaseIterable {
        case circle
        case square
        case triangle
        case diamond
        case star
        case hexagon
    }
    
    static var pointColors: [Color] {
        [
            .blue,
            .red,
            .green,
            .orange,
            .teal
        ]
    }

    let id = UUID()
    var name: String
    var width: Int
    var height: Int
    var meshPoints: [[MeshPoint]]
    var shadow: Color = .gray
    var withShadow: Bool = false
    var withBackground: Bool = false
    var backgroundColor: Color = .white
    
    init(name: String, width: Int, height: Int, meshPoints: [[MeshPoint]]) {
        self.name = name
        self.width = width
        self.height = height
        self.meshPoints = meshPoints
    }
    //\(String(format: "%.2f", point.xCoord))
    var code: String {
        var points = ""
        for row in meshPoints {
            var rowString = ""
            for meshPoint in row {
                rowString += ".init(\(String(format: "%.2f", meshPoint.point.xCoord)), \(String(format: "%.2f", meshPoint.point.yCoord))),"
            }
            points += rowString + "\n"
        }
        points = String(points.dropLast(2))
        
        var colors = ""
        for row in meshPoints {
            var rowString = ""
            for meshPoint in row {
                rowString += "Color(hex: \"\(meshPoint.point.color.toHexString() ?? "??")\")!,"
            }
            colors += rowString + "\n"
        }
        colors = String(colors.dropLast(2))
var code = """
// The Text Color initializer requires the two extensions available
// from https://github.com/StewartLynch/PlatformColorAndColorExtensions
// These will allow you to construct a Color view by providing a valid
// Hex string for a color.  Extensions work for both iOS and MacOS

MeshGradient(
    width: \(width),
    height: \(height),
    points: [
            \(points)
            ],
    colors: [
           \(colors)
            ]
"""
        if withBackground {
code += 
"""
,
    background: Color(hex: \"\(backgroundColor.toHexString() ?? "??")\")!
)
"""
        } else {
code += """
)
"""
            
        }
        
        return code
    }
    
    
    func generateSampleMeshPoints() -> [[MeshPoint]] {
        var rowBreaks: [CGFloat] {
            var rowBreaks: [CGFloat] = []
            (0...height-1).forEach { index in
                rowBreaks.append(CGFloat(index) / CGFloat(height-1))
            }
            return rowBreaks
        }
        var colBreaks: [CGFloat] {
            var colBreaks: [CGFloat] = []
            (0...width-1).forEach { index in
                colBreaks.append(CGFloat(index) / CGFloat(width-1))
            }
            return colBreaks
        }
        var allPoints: [[MeshPoint]] = []
        var symbols = MeshObject.Symbol.allCases
        (0..<height).forEach { row in
            let symbol = symbols.first
            var points: [MeshPoint] = []
            (0..<width).forEach { col in
                let newPoint = MeshPoint(
                    row: row,
                    col: col,
                    point: .init(
                        xCoord: colBreaks[col],
                        yCoord: rowBreaks[row],
                        color: MeshObject.colors.randomElement()!
                    ),
                    symbol: symbol!
                )
                points.append(newPoint)
            }
            symbols.removeFirst()
            allPoints.append(points)
        }

        return allPoints
    }
           
    static var sample: MeshObject {
        let newMeshObject = MeshObject(name: "Sample", width: 4, height: 3, meshPoints: [])
        let points = newMeshObject.generateSampleMeshPoints()
        newMeshObject.meshPoints = points
        return newMeshObject
    }
    
}

@Observable
class MeshPoint {
    var row: Int
    var col: Int
    var point: MPoint
    var symbol: MeshObject.Symbol
    init(row: Int, col: Int, point: MPoint, symbol: MeshObject.Symbol) {
        self.row = row
        self.col = col
        self.point = point
        self.symbol = symbol
    }
}

@Observable
class MPoint: Identifiable {
    var id = UUID()
    var xCoord: CGFloat
    var yCoord: CGFloat
    let dragOffset = CGSize.zero
    var color: Color
    
    init(id: UUID = UUID(), xCoord: CGFloat, yCoord: CGFloat, color: Color) {
        self.id = id
        self.xCoord = xCoord
        self.yCoord = yCoord
        self.color = color
    }
}
