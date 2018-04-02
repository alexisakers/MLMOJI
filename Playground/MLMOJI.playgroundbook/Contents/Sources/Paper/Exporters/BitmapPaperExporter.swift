//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit
import MobileCoreServices

/**
 * Exports papers to image bitmaps.
 */

public class BitmapPaperExporter: PaperExporter {

    /// The UTI of the image file format to use.
    public let fileType: CFString

    /**
     * Creates a bitmap exporter.
     *
     * - parameter size: The size of the image to export.
     * - parameter scale: The factor to multiply the image size.
     * - parameter fileType: The UTI of the image file format to use (ex: `kUTTypeJPEG`). Must
     * conform to `public.image`.
     */

    public init(size: CGSize, scale: CGFloat, fileType: CFString) {
        self.size = size
        self.fileType = fileType
        self.scale = scale
    }

    // MARK: - PaperExporter

    public let size: CGSize
    public let scale: CGFloat

    public func exportPaper(contents: CGImage) throws -> Data {

        let outputData = NSMutableData()

        guard UTTypeConformsTo(fileType, kUTTypeImage) else {
            throw NSError(domain: "FilePaperExporterDomain", code: 2001, userInfo: [
                NSLocalizedDescriptionKey: "The selected type '\(fileType)' is not an image type."
            ])
        }

        guard let destination = CGImageDestinationCreateWithData(outputData as CFMutableData, fileType, 1, nil) else {
            throw NSError(domain: "FilePaperExporterDomain", code: 2002, userInfo: [
                NSLocalizedDescriptionKey: "Could not create the destination for the image."
            ])
        }

        CGImageDestinationAddImage(destination, contents, nil)

        if !CGImageDestinationFinalize(destination) {
            throw NSError(domain: "FilePaperExporterDomain", code: 2003, userInfo: [
                NSLocalizedDescriptionKey: "Could not save image as a file."
            ])
        }

        return outputData as Data

    }

}
