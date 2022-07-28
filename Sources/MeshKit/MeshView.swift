//
//  MeshView.swift
//  
//
//  Created by Ethan Lipnik on 7/28/22.
//

import Foundation
import MeshGradient

#if canImport(AppKit)
public typealias Mesh = MeshView
#else
public typealias Mesh = MeshView
#endif

extension Mesh {
    public init(colors: Grid<MeshColor>,
                animatorConfiguration: MeshAnimator.Configuration,
                grainAlpha: Float = MeshGradientDefaults.grainAlpha,
                subdivisions: Int = MeshGradientDefaults.subdivisions) {
        self.init(initialGrid: colors.asControlPoint(), animatorConfiguration: animatorConfiguration, grainAlpha: grainAlpha, subdivisions: subdivisions)
    }
}
