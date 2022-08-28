//
//  MeshEditor.swift
//  
//
//  Created by Ethan Lipnik on 8/28/22.
//

import SwiftUI

public struct MeshEditor: View {
    @Binding public var colors: MeshColorGrid
    @Binding public var selectedPoint: MeshColor?
    public var meshRandomizer: MeshRandomizer?
    public var grainAlpha: Float
    public var subdivisions: Float
    public var colorSpace: CGColorSpace?
    
    @State private var currentOffset: CGSize = .zero
    
    public init(colors: Binding<MeshColorGrid>,
                selectedPoint: Binding<MeshColor?>,
                meshRandomizer: MeshRandomizer? = nil, 
                grainAlpha: Float = MeshDefaults.grainAlpha,
                subdivisions: Float = Float(MeshDefaults.subdivisions), 
                colorSpace: CGColorSpace? = nil) {
        self._colors = colors
        self._selectedPoint = selectedPoint
        self.meshRandomizer = meshRandomizer
        self.grainAlpha = grainAlpha
        self.subdivisions = subdivisions
        self.colorSpace = colorSpace
    }
    
    public var body: some View {
        ZStack {
            if let meshRandomizer {
                Mesh(colors: colors,
                     animatorConfiguration: .init(meshRandomizer: meshRandomizer),
                     grainAlpha: grainAlpha,
                     subdivisions: Int(subdivisions),
                     colorSpace: colorSpace)
            } else {
                Mesh(colors: colors,
                     grainAlpha: grainAlpha,
                     subdivisions: Int(subdivisions),
                     colorSpace: colorSpace)
            }
            
            GrabberView(grid: $colors, selectedPoint: $selectedPoint) { x, y, translation, _ in
                currentOffset = translation
            }
            .allowsHitTesting(meshRandomizer == nil)
            
            // This is used to update the view on drag.
            Text("\(currentOffset.width) \(currentOffset.height)").hidden()
        }
    }
}

struct EditingMeshView_Previews: PreviewProvider {
    static var previews: some View {
        MeshEditor(colors: .constant(MeshKit.generate(palette: .randomPalette())),
                        selectedPoint: .constant(nil))
    }
}
