//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import CoreGraphics
import CoreImage

/**
 * The filters that can be performed in a data set augmentation session.
 */

public enum AugmentationFilter {

    /// Rotates the image by the specified angle.
    case rotate(CGFloat)

    /// Translates the image to the given point on the screen.
    case translate(CGFloat, CGFloat)

    /// Applies
    case scale(CGFloat)

    /// Blurs the image.
    case blur

}
