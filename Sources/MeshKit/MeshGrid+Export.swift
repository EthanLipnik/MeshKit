//
//  MeshColorGrid+Export.swift
//
//
//  Created by Ethan Lipnik on 8/18/22.
//

import Accelerate
import CoreGraphics
import Foundation
import GLKit
import MeshGradient
import MetalKit
import UniformTypeIdentifiers

public extension MeshColorGrid {
    @discardableResult
    func export(
        to url: URL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".png"),
        size: MeshSize = .init(width: 1920, height: 1080),
        subdivisions: Int = MeshDefaults.subdivisions,
        grainAlpha: Float = MeshDefaults.grainAlpha,
        colorSpace: CGColorSpace? = .init(name: CGColorSpace.sRGB),
        fileFormat: UTType = .png,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let grid = self.asControlPoint()
            let dataProvider = MeshGradientState.static(grid: grid)
                .createDataProvider()
            let renderer = MetalMeshRenderer(
                metalKitView: nil,
                meshDataProvider: dataProvider,
                viewportSize: .init(
                    x: Float(size.width),
                    y: Float(size.height)
                ),
                grainAlpha: grainAlpha,
                subdivisions: subdivisions
            )

            var metalLayer: CAMetalLayer? = CAMetalLayer()
            metalLayer?.colorspace = colorSpace
            metalLayer?.framebufferOnly = false
            metalLayer?.device = MTLCreateSystemDefaultDevice()
            metalLayer?.setNeedsDisplay()
            metalLayer?.frame = CGRect(origin: .zero, size: CGSize(
                width: CGFloat(size.width),
                height: CGFloat(size.height)
            ))
            let currentDrwable = metalLayer?.nextDrawable()

            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
            renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store
            renderPassDescriptor.colorAttachments[0]
                .clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 0)
            renderPassDescriptor.colorAttachments[0].texture = currentDrwable?.texture

            renderer.draw(
                pixelFormat: pixelFormat,
                renderPassDescriptor: renderPassDescriptor,
                currentDrawable: currentDrwable
            ) { texture in
                if let texture {
                    texture.writeTexture(url: url, type: fileFormat, colorSpace: colorSpace)
                    continuation.resume(returning: url)
                } else {
                    continuation
                        .resume(throwing: NSError(domain: "Failed to create texture", code: -1))
                }

                metalLayer?.removeFromSuperlayer()
                metalLayer = nil
            }
        }
    }
}

extension MTLTexture {
#if os(iOS)
    typealias XImage = UIImage
#elseif os(macOS)
    typealias XImage = NSImage
#endif

    func makeImage(colorSpace: CGColorSpace? = nil) -> CGImage? {
        assert(pixelFormat == .bgra8Unorm)

        let width = width
        let height = height
        let pixelByteCount = 4 * MemoryLayout<UInt8>.size
        let imageBytesPerRow = width * pixelByteCount
        let imageByteCount = imageBytesPerRow * height
        let imageBytes = UnsafeMutableRawPointer.allocate(
            byteCount: imageByteCount,
            alignment: pixelByteCount
        )
        defer {
            imageBytes.deallocate()
        }

        getBytes(
            imageBytes,
            bytesPerRow: imageBytesPerRow,
            from: MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0
        )

        swizzleBGRA8toRGBA8(imageBytes, width: width, height: height)

        guard let colorSpace = CGColorSpace(name: colorSpace?.name ?? CGColorSpace.sRGB)
        else { return nil }
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let bitmapContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: imageBytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        bitmapContext.data?.copyMemory(from: imageBytes, byteCount: imageByteCount)
        let image = bitmapContext.makeImage()
        return image
    }

    func swizzleBGRA8toRGBA8(_ bytes: UnsafeMutableRawPointer, width: Int, height: Int) {
        var sourceBuffer = vImage_Buffer(
            data: bytes,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: width * 4
        )
        var destBuffer = vImage_Buffer(
            data: bytes,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: width * 4
        )
        var swizzleMask: [UInt8] = [2, 1, 0, 3] // BGRA -> RGBA
        vImagePermuteChannels_ARGB8888(
            &sourceBuffer,
            &destBuffer,
            &swizzleMask,
            vImage_Flags(kvImageNoFlags)
        )
    }

    func writeTexture(url: URL, type: UTType = .png, colorSpace: CGColorSpace? = nil) {
        guard let image = makeImage(colorSpace: colorSpace) else { return }

        if let imageDestination = CGImageDestinationCreateWithURL(
            url as CFURL,
            type.identifier as CFString,
            1,
            nil
        ) {
            CGImageDestinationAddImage(imageDestination, image, nil)
            CGImageDestinationFinalize(imageDestination)
        }
    }
}
