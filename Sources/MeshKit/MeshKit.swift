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
public typealias MeshColorGrid = MeshGradient.Grid<MeshColor>
public typealias ControlPoint = MeshGradient.ControlPoint
public typealias MeshGenerator = MeshGradient.MeshGenerator
public typealias MeshDefaults = MeshGradient.MeshGradientDefaults
public typealias StaticMeshDataProvider = MeshGradient.StaticMeshDataProvider
public typealias MeshDataProvider = MeshGradient.MeshDataProvider
public typealias MetalMeshRenderer = MeshGradient.MetalMeshRenderer
public typealias MeshAnimator = MeshGradient.MeshAnimator
public typealias MeshGrid = MeshGradient.Grid
public typealias MeshGradientState = MeshGradient.MeshGradientState

// MARK: - RandomColor
public typealias Hue = RandomColor.Hue
public typealias Luminosity = RandomColor.Luminosity

// MARK: - MeshKit
public actor MeshKit {
    private typealias Simd3 = SIMD3<Float>

    public static func generate(palette hues: Hue...,
                                luminosity: Luminosity = .bright,
                                size: MeshSize = .default,
                                withRandomizedLocations: Bool = false) -> MeshColorGrid {

        let colors: [SystemColor] = (hues + hues + hues).flatMap({
            randomColors(count: Int(ceil(Float(size.width * size.height) / Float(hues.count))),
                         hue: $0,
                         luminosity: luminosity)
        })

        let simdColors = colors.map({ $0.asSimd() })
        let meshRandomizer = MeshRandomizer(colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(availableColors: simdColors))

        let preparationGrid = MeshGrid<Simd3>(repeating: .zero, width: size.width, height: size.height)
        var result = MeshGenerator.generate(colorDistribution: preparationGrid)

        // And here we shuffle the grid using randomizer that we created
        for y in stride(from: 0, to: result.width, by: 1) {
            for x in stride(from: 0, to: result.height, by: 1) {
                if withRandomizedLocations {
                    meshRandomizer.locationRandomizer(&result[x, y].location, x, y, result.width, result.height)
                    meshRandomizer.turbulencyRandomizer(&result[x, y].uTangent, x, y, result.width, result.height)
                    meshRandomizer.turbulencyRandomizer(&result[x, y].vTangent, x, y, result.width, result.height)
                }
                meshRandomizer.colorRandomizer(&result[x, y].color, result[x, y].color, x, y, result.width, result.height)
            }
        }

        return result.asMeshColor()
    }
}
