//
//  MeshPoint.swift
//
//
//  Created by Ethan Lipnik on 7/29/22.
//

import Foundation

public struct MeshPoint: Codable, Hashable, Equatable {
    public init(x: Float = 0, y: Float = 0) {
        self.x = x
        self.y = y
    }

    public var x: Float
    public var y: Float

    public static var zero: MeshPoint {
        MeshPoint()
    }
}
