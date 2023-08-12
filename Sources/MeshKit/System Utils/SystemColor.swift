//
//  SystemColor.swift
//
//
//  Created by Ethan Lipnik on 7/27/22.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias SystemColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias SystemColor = NSColor
#endif
