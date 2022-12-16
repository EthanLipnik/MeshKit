//
//  MeshView.swift
//
//
//  Created by Ethan Lipnik on 7/28/22.
//

import Foundation
import MeshGradient
import MetalKit

#if canImport(AppKit)
public typealias Mesh = MeshView
#else
public typealias Mesh = MeshView
#endif

public extension Mesh {
    init(
        colors: MeshGrid<MeshColor>,
        animatorConfiguration: MeshAnimator.Configuration,
        grainAlpha: Float = MeshGradientDefaults.grainAlpha,
        subdivisions: Int = MeshGradientDefaults.subdivisions,
        colorSpace: CGColorSpace? = nil
    ) {
        self.init(
            initialGrid: colors.asControlPoint(),
            animatorConfiguration: animatorConfiguration,
            grainAlpha: grainAlpha,
            subdivisions: subdivisions,
            colorSpace: colorSpace
        )
    }

    init(
        colors: MeshGrid<MeshColor>,
        grainAlpha: Float = MeshGradientDefaults.grainAlpha,
        subdivisions: Int = MeshGradientDefaults.subdivisions,
        colorSpace: CGColorSpace? = nil
    ) {
        self.init(
            grid: colors.asControlPoint(),
            grainAlpha: grainAlpha,
            subdivisions: subdivisions,
            colorSpace: colorSpace
        )
    }
}

public extension MTKView {
    func export() -> CIImage? {
        guard let texture = currentDrawable?.texture else { return nil }
        return CIImage(mtlTexture: texture)
    }
}
