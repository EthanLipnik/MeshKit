//
//  MeshColor.swift
//  
//
//  Created by Ethan Lipnik on 7/27/22.
//

import Foundation

public struct MeshColor: Equatable, Codable {
    public static func == (lhs: MeshColor, rhs: MeshColor) -> Bool {
        return lhs.location == rhs.location && lhs.color == rhs.color && lhs.tangent == rhs.tangent
    }

    public init(location: (x: Float, y: Float) = (0, 0), color: SystemColor = .white, tangent: (u: MeshSize, v: MeshSize) = (.zero, .zero)) {
        self.location = location
        self.color = color
        self.tangent = tangent
    }

    public var location: (x: Float, y: Float)
    public var color: SystemColor
    public var tangent: (u: MeshSize, v: MeshSize)

    public func asSimd() -> SIMD3<Float> {
        return color.asSimd()
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

        let locationX = try container.decode(Float.self, forKey: .locationX)
        let locationY = try container.decode(Float.self, forKey: .locationY)
        self.location = (locationX, locationY)

        self.color = try container.decode(CodableColor.self, forKey: .color).uiColor

        if let tangentU = try? container.decode(MeshSize.self, forKey: .tangentU),
           let tangentV = try? container.decode(MeshSize.self, forKey: .tangentV) {
            self.tangent = (tangentU, tangentV)
        } else {
            self.tangent = (.zero, .zero)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(location.x, forKey: .locationX)
        try container.encode(location.y, forKey: .locationY)

        try container.encode(CodableColor(uiColor: color), forKey: .color)

        try container.encode(tangent.u, forKey: .tangentU)
        try container.encode(tangent.v, forKey: .tangentV)
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
