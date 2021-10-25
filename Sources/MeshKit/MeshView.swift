//
//  MeshView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SceneKit

public class MeshView: UIView {

    // MARK: - Views
    public lazy var scene: SCNScene = {
        let scene = SCNScene()
        
        return scene
    }()
    public lazy var sceneView: SCNView = {
        let view = SCNView()
        
        view.scene = scene
        view.allowsCameraControl = false
        view.debugOptions = debugOptions
        view.isUserInteractionEnabled = false
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Variables
    public lazy var debugOptions: SCNDebugOptions = [] {
        didSet {
            sceneView.debugOptions = debugOptions
        }
    }
    
    public lazy var scaleFactor: CGFloat = contentScaleFactor {
        didSet {
            sceneView.contentScaleFactor = contentScaleFactor
        }
    }
    
    // MARK: - Setup
    public init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private final func setup() {
        addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public final func create(_ colors: [MeshNode.Color], width: Int = 3, height: Int = 3, subdivisions: Int = 18) {
        let elements = MeshNode.generateElements(width:width,
                                                 height: height,
                                                 colors: colors, subdivisions: subdivisions)
        
        if let node = scene.rootNode.childNode(withName: "meshNode",
                                               recursively: false) {
            node.geometry = SCNNode.get(points: elements.points,
                                        colors: elements.colors)
        } else {
            let node = MeshNode.node(elements: elements)
            node.name = "meshNode"
            
            scene.rootNode.addChildNode(node)
        }
    }
    
    public final func snapshot() -> UIImage {
        return sceneView.snapshot()
    }
    
    public final func generate(size: CGSize) -> UIImage {
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
        renderer.isPlaying = true
        
        renderer.scene = scene
        
        let renderTime = TimeInterval(20)
        
        for i in 0..<60 * 10 {
            renderer.update(atTime: Date.timeIntervalSinceReferenceDate * (1.0 / 60 * Double(i)))
        }
        renderer.sceneTime = renderTime
        renderer.isJitteringEnabled = true
        
        return renderer.snapshot(atTime: renderTime, with: size, antialiasingMode: .multisampling4X)
    }
}
