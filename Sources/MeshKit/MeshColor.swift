//
//  MeshColor.swift
//
//
//  Created by Ethan Lipnik on 7/27/22.
//

import CoreGraphics
import Foundation
import RandomColor

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public class MeshColor: Equatable, Hashable, Codable {
    public static func == (lhs: MeshColor, rhs: MeshColor) -> Bool {
        lhs.location == rhs.location && lhs.color == rhs.color && lhs.tangent == rhs.tangent
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(startLocation)
        hasher.combine(location)
        hasher.combine(color)
        hasher.combine(tangent)
    }

    public init(
        startLocation: MeshPoint = .zero,
        location: MeshPoint = .zero,
        color: SystemColor = .white,
        tangent: MeshTangent = .zero
    ) {
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
        color.asSimd()
    }

    enum CodingKeys: String, CodingKey {
        case startLocation
        case location

        case color
        case tangent
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startLocation = try container.decode(MeshPoint.self, forKey: .startLocation)
        location = try container.decode(MeshPoint.self, forKey: .location)
        color = try container.decode(CodableColor.self, forKey: .color).uiColor
        tangent = try container.decode(MeshTangent.self, forKey: .tangent)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(startLocation, forKey: .startLocation)
        try container.encode(location, forKey: .location)
        try container.encode(CodableColor(uiColor: color), forKey: .color)
        try container.encode(tangent, forKey: .tangent)
    }

    struct CodableColor: Codable {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

        var uiColor: SystemColor {
            SystemColor(red: red, green: green, blue: blue, alpha: alpha)
        }

        init(uiColor: SystemColor) {
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
    }
}

public extension SystemColor {
    func asSimd() -> SIMD3<Float> {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return SIMD3<Float>(Float(red), Float(green), Float(blue))
    }
}

public extension Hue {
    static var allCases: [Hue] {
        [
            .blue,
            .orange,
            .yellow,
            .green,
            .pink,
            .purple,
            .red,
            .monochrome,
            .random
        ]
    }

    var displayTitle: String {
        switch self {
        case .monochrome:
            return "Monochrome"
        case .red:
            return "Red"
        case .orange:
            return "Orange"
        case .yellow:
            return "Yellow"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .purple:
            return "Purple"
        case .pink:
            return "Pink"
        case .random:
            return "Random"
        default:
            return "Unknown Palette"
        }
    }

    static func randomPalette(includesMonochrome: Bool = true) -> Hue {
        var hues = allCases

        if !includesMonochrome {
            hues.removeLast()
        }

        return hues.randomElement() ?? .monochrome
    }
}
