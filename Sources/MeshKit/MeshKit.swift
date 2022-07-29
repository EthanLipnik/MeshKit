//
//  MeshKit.swift
//  
//
//  Created by Ethan Lipnik on 7/27/22.
//

import Foundation
import MeshGradient
import RandomColor
import CoreGraphics

// MARK: - MeshGradient
public typealias MeshRandomizer = MeshGradient.MeshRandomizer
public typealias MeshGrid = MeshGradient.Grid<MeshColor>
public typealias ControlPoint = MeshGradient.ControlPoint
public typealias MeshGenerator = MeshGradient.MeshGenerator
public typealias MeshDefaults = MeshGradientDefaults

// MARK: - RandomColor
public typealias Hue = RandomColor.Hue
public typealias Luminosity = RandomColor.Luminosity

// MARK: - MeshKit
public actor MeshKit {
    private typealias Simd3 = SIMD3<Float>

    public static func generate(palette hues: Hue...,
                                luminosity: Luminosity = .bright,
                                size: MeshSize = .default) -> MeshGrid {

        let colors: [SystemColor] = (hues + hues + hues).flatMap({
            randomColors(count: Int(ceil(Float(size.width * size.height) / Float(hues.count))),
                         hue: $0,
                         luminosity: luminosity)
        })

        let simdColors = colors.map({ $0.asSimd() })
        let meshRandomizer = MeshRandomizer(colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(availableColors: simdColors))

        let preparationGrid = Grid<Simd3>(repeating: .zero, width: size.width, height: size.height)
        var result = MeshGenerator.generate(colorDistribution: preparationGrid)

        // And here we shuffle the grid using randomizer that we created
        for y in stride(from: 0, to: result.width, by: 1) {
            for x in stride(from: 0, to: result.height, by: 1) {
                meshRandomizer.locationRandomizer(&result[x, y].location, x, y, result.width, result.height)
                meshRandomizer.turbulencyRandomizer(&result[x, y].uTangent, x, y, result.width, result.height)
                meshRandomizer.turbulencyRandomizer(&result[x, y].vTangent, x, y, result.width, result.height)

                meshRandomizer.colorRandomizer(&result[x, y].color, result[x, y].color, x, y, result.width, result.height)
            }
        }

        return result.asMeshColor()
    }
}

extension Grid where Element == ControlPoint {
    public func asMeshColor() -> Grid<MeshColor> {
        var grid = Grid<MeshColor>(repeating: .init(), width: width, height: height)
        grid.elements = {
            var colors: ContiguousArray<MeshColor> = []
            for y in stride(from: 0, to: self.width, by: 1) {
                for x in stride(from: 0, to: self.height, by: 1) {
                    let point = self[x, y]
                    colors.append(
                        MeshColor(
                            startLocation: MeshPoint(x: point.location.x, y: point.location.y),
                            location: MeshPoint(x: point.location.x, y: point.location.y),
                            color: SystemColor(red: CGFloat(point.color.x),
                                               green: CGFloat(point.color.y),
                                               blue: CGFloat(point.color.z),
                                               alpha: 1),
                            tangent: MeshTangent(u: MeshPoint(x: point.uTangent.x, y: point.uTangent.y),
                                                 v: MeshPoint(x: point.vTangent.x, y: point.vTangent.y))
                        )
                    )
                }
            }

            return colors
        }()

        return grid
    }
}

extension Grid where Element == MeshColor {

    private typealias simd_float2 = SIMD2<Float>

    public func asControlPoint() -> Grid<ControlPoint> {
        var grid = Grid<ControlPoint>(repeating: .zero, width: width, height: height)
        grid.elements = {
            var controlPoints: ContiguousArray<ControlPoint> = []
            for y in stride(from: 0, to: self.width, by: 1) {
                for x in stride(from: 0, to: self.height, by: 1) {
                    let color = self[x, y]
                    controlPoints.append(
                        ControlPoint(
                            color: color.asSimd(),
                            location: simd_float2(color.location.x, color.location.y),
                            uTangent: simd_float2(color.tangent.u.x,
                                                  color.tangent.u.y),
                            vTangent: simd_float2(color.tangent.v.x,
                                                  color.tangent.v.y)
                        )
                    )
                }
            }

            return controlPoints
        }()

        return grid
    }
    
    public func isEdge(x: Int, y: Int) -> Bool {
        return !(x != 0 && x != width - 1 && y != 0 && y != height - 1)
    }
}

extension MeshRandomizer {
    public static func withMeshColors(_ meshColors: Grid<MeshColor>) -> MeshRandomizer {
        MeshRandomizer(
            colorRandomizer: MeshRandomizer
                .arrayBasedColorRandomizer(availableColors: meshColors.elements.map({ $0.asSimd() }))
        )
    }
}
