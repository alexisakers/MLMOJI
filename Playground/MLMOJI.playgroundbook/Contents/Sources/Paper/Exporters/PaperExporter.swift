//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * You implement this protocol to provide a way to export the sketches in a `Paper` instance.
 */

public protocol PaperExporter {

    /**
     * The type of output values produced by the exporter. Can be any type.
     */

    associatedtype Output

    /// The size of the exported image, in points.
    var size: CGSize { get }

    /// The display scale to use to export the image.
    var scale: CGFloat { get }

    /**
     * Process the contents of the paper, provided as a `CGImage` and convert it to the
     * object your exporter provides.
     */

    func exportPaper(contents: CGImage) throws -> Output

}
