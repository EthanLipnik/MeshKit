//
//  MeshScene.swift
//  
//
//  Created by Ethan Lipnik on 3/23/22.
//

import SceneKit

open class MeshScene: SCNScene {
    public final func create(_ colors: [MeshNode.Color], width: Int = 3, height: Int = 3, subdivisions: Int = 18) {
        let elements = MeshNode.generateElements(width:width,
                                                 height: height,
                                                 colors: colors, subdivisions: subdivisions)
        
        if let node = rootNode.childNode(withName: "meshNode",
                                               recursively: false) {
            node.geometry = SCNNode.get(points: elements.points,
                                        colors: elements.colors)
        } else {
            let node = MeshNode.node(elements: elements)
            node.name = "meshNode"
            
            rootNode.addChildNode(node)
        }
    }
    
    public final func generate(size: CGSize) -> UIImage {
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice())
        renderer.scene = self
        return renderer.snapshot(atTime: .zero, with: size, antialiasingMode: .none)
    }
}
