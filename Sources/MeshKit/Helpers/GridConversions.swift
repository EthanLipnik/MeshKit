//
//  GridConversions.swift
//
//
//  Created by Ethan Lipnik on 8/18/22.
//

import Foundation
import MeshGradient

public extension Grid where Element == ControlPoint {
    func asMeshColor() -> MeshGrid<MeshColor> {
        var grid = MeshGrid<MeshColor>(repeating: .init(), width: width, height: height)
        grid.elements = {
            var colors: ContiguousArray<MeshColor> = []
            for y in stride(from: 0, to: self.width, by: 1) {
                for x in stride(from: 0, to: self.height, by: 1) {
                    let point = self[x, y]
                    colors.append(
                        MeshColor(
                            startLocation: MeshPoint(x: point.location.x, y: point.location.y),
                            location: MeshPoint(x: point.location.x, y: point.location.y),
                            color: SystemColor(
                                red: CGFloat(point.color.x),
                                green: CGFloat(point.color.y),
                                blue: CGFloat(point.color.z),
                                alpha: 1
                            ),
                            tangent: MeshTangent(
                                u: MeshPoint(x: point.uTangent.x, y: point.uTangent.y),
                                v: MeshPoint(x: point.vTangent.x, y: point.vTangent.y)
                            )
                        )
                    )
                }
            }

            return colors
        }()

        return grid
    }
}

public extension Grid where Element == MeshColor {
    private typealias simd_float2 = SIMD2<Float>

    func asControlPoint() -> MeshGrid<ControlPoint> {
        var grid = MeshGrid<ControlPoint>(repeating: .zero, width: width, height: height)
        grid.elements = {
            var controlPoints: ContiguousArray<ControlPoint> = []
            for y in stride(from: 0, to: self.width, by: 1) {
                for x in stride(from: 0, to: self.height, by: 1) {
                    let color = self[x, y]
                    controlPoints.append(
                        ControlPoint(
                            color: color.asSimd(),
                            location: simd_float2(color.location.x, color.location.y),
                            uTangent: simd_float2(
                                color.tangent.u.x,
                                color.tangent.u.y
                            ),
                            vTangent: simd_float2(
                                color.tangent.v.x,
                                color.tangent.v.y
                            )
                        )
                    )
                }
            }

            return controlPoints
        }()

        return grid
    }

    func isEdge(x: Int, y: Int) -> Bool {
        return !(x != 0 && x != width - 1 && y != 0 && y != height - 1)
    }
}

public extension MeshRandomizer {
    static func withMeshColors(_ meshColors: MeshGrid<MeshColor>) -> MeshRandomizer {
        MeshRandomizer(
            colorRandomizer: MeshRandomizer
                .arrayBasedColorRandomizer(availableColors: meshColors.elements.map { $0.asSimd() })
        )
    }
}
