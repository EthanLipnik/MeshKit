//
//  MeshView.swift
//  
//
//  Created by Ethan Lipnik on 7/28/22.
//

import Foundation
import MeshGradient

#if canImport(AppKit)
public typealias MeshView = AnimatableMeshGradient
#else
public typealias MeshView = MeshView
#endif

extension MeshView {
    public init(colors: Grid<MeshColor>,
                animatorConfiguration: MeshAnimator.Configuration,
                grainAlpha: Float = MeshGradientDefaults.grainAlpha,
                subdivisions: Int = MeshGradientDefaults.subdivisions) {
        self.init(initialGrid: colors.asControlPoint(), animatorConfiguration: animatorConfiguration, grainAlpha: grainAlpha, subdivisions: subdivisions)
    }
}
