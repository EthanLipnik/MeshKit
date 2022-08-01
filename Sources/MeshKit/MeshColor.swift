//
//  MeshColor.swift
//  
//
//  Created by Ethan Lipnik on 7/27/22.
//

import Foundation
import CoreGraphics
import RandomColor

public class MeshColor: Equatable, Hashable, Codable {
    public static func == (lhs: MeshColor, rhs: MeshColor) -> Bool {
        return lhs.location == rhs.location && lhs.color == rhs.color && lhs.tangent == rhs.tangent
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(startLocation)
        hasher.combine(location)
        hasher.combine(color)
        hasher.combine(tangent)
    }

    public init(startLocation: MeshPoint = .zero, location: MeshPoint = .zero, color: SystemColor = .white, tangent: MeshTangent = .zero) {
        self.startLocation = startLocation
        self.location = location
        self.color = color
        self.tangent = tangent
    }

    public var startLocation: MeshPoint
    public var location: MeshPoint
    public var color: SystemColor
    public var tangent: MeshTangent

    public func asSimd() -> SIMD3<Float> {
        return color.asSimd()
    }

    enum CodingKeys: String, CodingKey {
        case startLocation
        case location

        case color
        case tangent
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.startLocation = try container.decode(MeshPoint.self, forKey: .startLocation)
        self.location = try container.decode(MeshPoint.self, forKey: .location)
        self.color = try container.decode(CodableColor.self, forKey: .color).uiColor
        self.tangent = try container.decode(MeshTangent.self, forKey: .tangent)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(startLocation, forKey: .startLocation)
        try container.encode(location, forKey: .location)
        try container.encode(CodableColor(uiColor: color), forKey: .color)
        try container.encode(tangent, forKey: .tangent)
    }

    struct CodableColor : Codable {
        var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

        var uiColor : SystemColor {
            return SystemColor(red: red, green: green, blue: blue, alpha: alpha)
        }

        init(uiColor : SystemColor) {
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
    }
}

extension SystemColor {
    public func asSimd() -> SIMD3<Float> {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return SIMD3<Float>(Float(red), Float(green), Float(blue))
    }
}

extension Hue {
    public static var allCases: [Hue] {
        get {
            return [
                .blue,
                .orange,
                .yellow,
                .green,
                .pink,
                .purple,
                .red,
                .monochrome
            ]
        }
    }
    
    public static func randomPalette(includesMonochrome: Bool = true) -> Hue {
        var hues = allCases
        
        if !includesMonochrome {
            hues.removeLast()
        }
        
        return hues.randomElement() ?? .monochrome
    }
}
