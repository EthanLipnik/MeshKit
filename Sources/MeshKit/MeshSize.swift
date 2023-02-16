//
//  MeshSize.swift
//
//
//  Created by Ethan Lipnik on 7/27/22.
//

import Foundation

public struct MeshSize: Codable, Hashable {
    public init(width: Int = 3, height: Int = 3) {
        self.width = width
        self.height = height
    }

    public var width: Int
    public var height: Int

    public static var `default`: MeshSize {
        .init()
    }

    public static var zero: MeshSize {
        .init(width: 0, height: 0)
    }
}
