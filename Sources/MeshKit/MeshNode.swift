//
//  MeshNode.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SceneKit

public class MeshNode {
    
    private let linearSRGCColorSpace = CGColorSpace(name: CGColorSpace.linearSRGB)!
    
    public struct ControlPoint {
        public init(color: simd_float3 = simd_float3(0, 0, 0), location: simd_float2 = simd_float2(0, 0), uTangent: simd_float2 = simd_float2(0, 0), vTangent: simd_float2 = simd_float2(0, 0)) {
            self.color = color
            self.location = location
            self.uTangent = uTangent
            self.vTangent = vTangent
        }
        
        public var color: simd_float3 = simd_float3(0, 0, 0)
        public var location: simd_float2 = simd_float2(0, 0)
        public var uTangent: simd_float2 = simd_float2(0, 0)
        public var vTangent: simd_float2 = simd_float2(0, 0)
    }
    
    public struct Elements {
        public init(points: Grid<simd_float2>, colors: Grid<simd_float3>) {
            self.points = points
            self.colors = colors
        }
        
        public var points: Grid<simd_float2>
        public var colors: Grid<simd_float3>
    }
    
    public struct Color: Identifiable, Equatable, Codable {
        public static func == (lhs: MeshNode.Color, rhs: MeshNode.Color) -> Bool {
            return lhs.id == rhs.id && lhs.color == rhs.color
        }
        
        public var id: String {
            return "\(point.x)\(point.y)"
        }
        
        public init(point: (x: Int, y: Int), location: (x: Float, y: Float), color: UIColor, tangent: (u: Float, v: Float)) {
            self.point = point
            self.location = location
            self.color = color
            self.tangent = tangent
        }
        
        public var point: (x: Int, y: Int)
        public var location: (x: Float, y: Float)
        public var color: UIColor
        public var tangent: (u: Float, v: Float)
        
        public func colorToSimd() -> simd_float3 {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0

            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return simd_float3(Float(red), Float(green), Float(blue))
        }
        
        enum CodingKeys: String, CodingKey {
            case pointX
            case pointY
            
            case locationX
            case locationY
            
            case color
            case tangentU
            case tangentV
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let pointX = try container.decode(Int.self, forKey: .pointX)
            let pointY = try container.decode(Int.self, forKey: .pointY)
            self.point = (pointX, pointY)
            
            let locationX = try container.decode(Float.self, forKey: .locationX)
            let locationY = try container.decode(Float.self, forKey: .locationY)
            self.location = (locationX, locationY)
            
            self.color = try container.decode(CodableColor.self, forKey: .color).uiColor
            
            let tangentU = try container.decode(Float.self, forKey: .tangentU)
            let tangentV = try container.decode(Float.self, forKey: .tangentV)
            self.tangent = (tangentU, tangentV)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(point.x, forKey: .pointX)
            try container.encode(point.y, forKey: .pointY)
            
            try container.encode(location.x, forKey: .locationX)
            try container.encode(location.y, forKey: .locationY)
            
            try container.encode(CodableColor(uiColor: color), forKey: .color)
            
            try container.encode(tangent.u, forKey: .tangentU)
            try container.encode(tangent.v, forKey: .tangentV)
        }
        
        struct CodableColor : Codable {
            var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
            
            var uiColor : UIColor {
                return UIColor(red: red, green: green, blue: blue, alpha: alpha)
            }
            
            init(uiColor : UIColor) {
                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            }
        }
    }
    
    public static func node(elements: Elements) -> SCNNode {
        return SCNNode(points: elements.points, colors: elements.colors)
    }
    
    public static func generateElements(width: Int, height: Int, colors: [Color], subdivisions: Int) -> Elements {
        /// This math is from https://github.com/movingparts-io/Gradient-Meshes-with-SceneKit
        let H = simd_float4x4(rows: [
            simd_float4( 2, -2,  1,  1),
            simd_float4(-3,  3, -2, -1),
            simd_float4( 0,  0,  1,  0),
            simd_float4( 1,  0,  0,  0)
        ])
        
        let H_T = H.transpose
        
        func surfacePoint(u: Float, v: Float, X: simd_float4x4, Y: simd_float4x4) -> simd_float2 {
            let U = simd_float4(u * u * u, u * u, u, 1)
            let V = simd_float4(v * v * v, v * v, v, 1)
            
            return simd_float2(
                dot(V, U * H * X * H_T),
                dot(V, U * H * Y * H_T)
            )
        }
        
        func meshCoefficients(_ p00: ControlPoint, _ p01: ControlPoint, _ p10: ControlPoint, _ p11: ControlPoint, axis: KeyPath<simd_float2, Float>) -> simd_float4x4 {
            func l(_ controlPoint: ControlPoint) -> Float {
                controlPoint.location[keyPath: axis]
            }
            
            func u(_ controlPoint: ControlPoint) -> Float {
                controlPoint.uTangent[keyPath: axis]
            }
            
            func v(_ controlPoint: ControlPoint) -> Float {
                controlPoint.vTangent[keyPath: axis]
            }
            
            return simd_float4x4(rows: [
                simd_float4(l(p00), l(p01), v(p00), v(p01)),
                simd_float4(l(p10), l(p11), v(p10), v(p11)),
                simd_float4(u(p00), u(p01),      0,      0),
                simd_float4(u(p10), u(p11),      0,      0)
            ])
        }
        
        func colorCoefficients(_ p00: ControlPoint, _ p01: ControlPoint, _ p10: ControlPoint, _ p11: ControlPoint, axis: KeyPath<simd_float3, Float>) -> simd_float4x4 {
            func l(_ point: ControlPoint) -> Float {
                point.color[keyPath: axis]
            }
            
            return simd_float4x4(rows: [
                simd_float4(l(p00), l(p01), 0, 0),
                simd_float4(l(p10), l(p11), 0, 0),
                simd_float4(     0,      0, 0, 0),
                simd_float4(     0,      0, 0, 0)
            ])
        }
        
        func colorPoint(u: Float, v: Float, R: simd_float4x4, G: simd_float4x4, B: simd_float4x4) -> simd_float3 {
            let U = simd_float4(u * u * u, u * u, u, 1)
            let V = simd_float4(v * v * v, v * v, v, 1)
            
            return simd_float3(
                dot(V, U * H * R * H_T),
                dot(V, U * H * G * H_T),
                dot(V, U * H * B * H_T)
            )
        }
        
        func bilinearInterpolation(u: Float, v: Float, _ c00: ControlPoint, _ c01: ControlPoint, _ c10: ControlPoint, _ c11: ControlPoint) -> simd_float3 {
            let r = simd_float2x2(rows: [
                simd_float2(c00.color.x, c01.color.x),
                simd_float2(c10.color.x, c11.color.x),
            ])
            
            let g = simd_float2x2(rows: [
                simd_float2(c00.color.y, c01.color.y),
                simd_float2(c10.color.y, c11.color.y),
            ])
            
            let b = simd_float2x2(rows: [
                simd_float2(c00.color.z, c01.color.z),
                simd_float2(c10.color.z, c11.color.z),
            ])
            
            let r_ = dot(simd_float2(1 - u, u), r * simd_float2(1 - v, v))
            let g_ = dot(simd_float2(1 - u, u), g * simd_float2(1 - v, v))
            let b_ = dot(simd_float2(1 - u, u), b * simd_float2(1 - v, v))
            
            return simd_float3(r_, g_, b_)
        }
        
        var grid = Grid(repeating: ControlPoint(), width: width, height: height)
        for color in colors {
            grid[color.point.x, color.point.y].color = color.colorToSimd()
        }
        
        for y in 0 ..< grid.height {
            for x in 0 ..< grid.width {
                
                if let color = colors.first(where: { $0.point.x == x && $0.point.y == y }) {
                    grid[x, y].uTangent.x = color.tangent.u / Float(grid.width  - 1)
                    grid[x, y].vTangent.y = color.tangent.v / Float(grid.height - 1)
                    
                    grid[x, y].location = simd_float2(
                        lerp(color.location.x / Float(grid.width  - 1), -1, 1),
                        lerp(color.location.y / Float(grid.height - 1), -1, 1)
                    )
                } else {
                    grid[x, y].uTangent.x = 2 / Float(grid.width  - 1)
                    grid[x, y].vTangent.y = 2 / Float(grid.height - 1)
                    
                    grid[x, y].location = simd_float2(
                        lerp(Float(x) / Float(grid.width  - 1), -1, 1),
                        lerp(Float(y) / Float(grid.height - 1), -1, 1)
                    )
                }
            }
        }
        
        var points = Grid(
            repeating: simd_float2(0, 0),
            width: (grid.width - 1) * subdivisions,
            height: (grid.height - 1) * subdivisions
        )
        
        var colors = Grid(
            repeating: simd_float3(0, 0 , 0),
            width: (grid.width - 1) * subdivisions,
            height: (grid.height - 1) * subdivisions
        )
        
        for x in 0 ..< grid.width - 1 {
            for y in 0 ..< grid.height - 1 {
                // The four control points in the corners of the current patch.
                let p00 = grid[    x,     y]
                let p01 = grid[    x, y + 1]
                let p10 = grid[x + 1,     y]
                let p11 = grid[x + 1, y + 1]
                
                // The X and Y coefficient matrices for the current Hermite patch.
                let X = meshCoefficients(p00, p01, p10, p11, axis: \.x)
                let Y = meshCoefficients(p00, p01, p10, p11, axis: \.y)
                
                // The coefficients matrices for the current hermite patch in RGB
                // space
                let R = colorCoefficients(p00, p01, p10, p11, axis: \.x)
                let G = colorCoefficients(p00, p01, p10, p11, axis: \.y)
                let B = colorCoefficients(p00, p01, p10, p11, axis: \.z)
                
                for u in 0 ..< subdivisions {
                    for v in 0 ..< subdivisions {
                        points[x * subdivisions + u, y * subdivisions + v] =
                        surfacePoint(
                            u: Float(u) / Float(subdivisions - 1),
                            v: Float(v) / Float(subdivisions - 1),
                            X: X,
                            Y: Y
                        )
                        
                        // Compare against bilinear interpolation here by using
                        //
                        //     bilinearInterpolation(
                        //         u: Float(u) / Float(subdivisions - 1),
                        //         v: Float(v) / Float(subdivisions - 1),
                        //         c00, c01, c10, c11)
                        //
                        colors[x * subdivisions + u, y * subdivisions + v] =
                        colorPoint(
                            u: Float(u) / Float(subdivisions - 1),
                            v: Float(v) / Float(subdivisions - 1),
                            R: R, G: G, B: B
                        )
                    }
                }
            }
        }
        
        return .init(points: points, colors: colors)
    }
}
