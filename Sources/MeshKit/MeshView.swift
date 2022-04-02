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
    public lazy var scene: MeshScene = {
        let scene = MeshScene()
        
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
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.scene.create(colors, width: width, height: height, subdivisions: subdivisions)
        }
    }
    
    public final func snapshot() -> UIImage {
        return sceneView.snapshot()
    }
    
    public final func generate(size: CGSize) -> UIImage {
        return scene.generate(size: size)
    }
}
