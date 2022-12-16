//
//  MeshTangent.swift
//
//
//  Created by Ethan Lipnik on 7/29/22.
//

import Foundation

public struct MeshTangent: Codable, Hashable, Equatable {
    public init(u: MeshPoint = .zero, v: MeshPoint = .zero) {
        self.u = u
        self.v = v
    }

    public var u: MeshPoint
    public var v: MeshPoint

    public static var zero: MeshTangent {
        return MeshTangent(u: .zero, v: .zero)
    }
}
