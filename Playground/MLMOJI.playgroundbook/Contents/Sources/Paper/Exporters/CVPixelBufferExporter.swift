//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit
import CoreVideo

/**
 * Exports images to a CVPixelBuffer.
 */

public class CVPixelBufferExporter: PaperExporter {

    public init(size: CGSize, scale: CGFloat) {
        self.size = size
        self.scale = scale
    }

    public let size: CGSize
    public let scale: CGFloat

    public func exportPaper(contents: CGImage) throws -> CVPixelBuffer {

        // Create an empty image buffer that fits the size of the image

        let imageWidth = Int(size.width * scale)
        let imageHeight = Int(size.height * scale)

        var buffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, imageWidth, imageHeight, kCVPixelFormatType_32BGRA, nil, &buffer)

        guard status == kCVReturnSuccess else {
            throw NSError(domain: "CVPixelBufferExporter", code: 2001, userInfo: [
                NSLocalizedDescriptionKey: "Could not create the pixel buffer for the image (code \(status))."
            ])
        }

        guard let pixelBuffer = buffer else {
            throw NSError(domain: "CVPixelBufferExporter", code: 2002, userInfo: [
                NSLocalizedDescriptionKey: "Could not create the pixel buffer for the image."
            ])
        }

        // Draw the image into the buffer's context

        CVPixelBufferLockBaseAddress(pixelBuffer, [])

        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        let ctx = CGContext(data: data, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                            space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        guard let pixelBufferContext = ctx else {
            throw NSError(domain: "CVPixelBufferExporter", code: 2003, userInfo: [
                NSLocalizedDescriptionKey: "Could not create the context to draw the image."
            ])
        }

        pixelBufferContext.draw(contents, in: CGRect(origin: .zero, size: size))

        // Return the filled buffer
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        return pixelBuffer

    }

}
