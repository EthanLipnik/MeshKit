//
//  SystemImage.swift
//
//
//  Created by Ethan Lipnik on 7/27/22.
//

import Foundation

import Foundation

#if canImport(UIKit)
import UIKit
public typealias SystemImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias SystemImage = NSImage
#endif
