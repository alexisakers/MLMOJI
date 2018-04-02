//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * The delegate of an image augmentation session.
 */

public protocol AugmentationSessionDelegate: class {

    /**
     * Called when the augmentation session added an image.
     */

    func augmentationSession(_ session: AugmentationSession, didCreateImage image: UIImage)

    /**
     * Called when the augmentation session finishes.
     */

    func augmentationSessionDidFinish(_ session: AugmentationSession)

}

/**
 * An object that augments an image.
 */

public class AugmentationSession: NSObject {

    /// The filters to apply.
    public let actions: [AugmentationFilter]

    /// The size of images.
    public let imageSize = CGSize(width: 250, height: 250)

    /// The session delegate.
    public weak var delegate: AugmentationSessionDelegate?

    /// The background queue where the augmentation work will be executed.
    private let workQueue = DispatchQueue(label: "AugmentationSession.Work")

    // MARK: - Initialization

    public init(actions: [AugmentationFilter]) {
        self.actions = actions
    }

    // MARK: - Filters

    /**
     * Starts a session with a delegate and an initial image.
     *
     * The filters will be applied cumulatively to the initial image.
     */

    public func start(initialImage: CGImage) {
        workQueue.async {
            self.applyFilters(start: initialImage)
        }
    }

    /**
     * Applies the filter to an image.
     */

    private func applyFilters(start: CGImage) {

        var current = start

        for action in actions {

            let imageBounds = CGRect(origin: .zero, size: self.imageSize)
            var outputImage: CGImage
            var needsFlip: Bool = false

            switch action {
            case .blur:
                let ciImage = CIImage(cgImage: current)

                let filter = CIFilter(name: "CIGaussianBlur")!
                filter.setValue(5, forKey: "inputRadius")
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                let filteredImage = filter.outputImage!

                let context = CIContext(options: [kCIContextUseSoftwareRenderer: true])
                outputImage = context.createCGImage(filteredImage, from: ciImage.extent)!
                needsFlip = true

            default:
                var transform = CGAffineTransform.identity
                switch action {
                case .rotate(let degreeAngle):
                    transform = transform
                        .translatedBy(x: imageBounds.size.width / 2, y: imageBounds.size.height / 2)
                        .rotated(by: -degreeAngle * .pi / 180)
                        .translatedBy(x: -imageBounds.size.width / 2, y: -imageBounds.size.height / 2)
                    
                case .scale(let scale):
                    transform = transform
                        .translatedBy(x: imageBounds.size.width / 2, y: imageBounds.size.height / 2)
                        .scaledBy(x: scale / 100, y: scale / 100)
                        .translatedBy(x: -imageBounds.size.width / 2, y: -imageBounds.size.height / 2)

                case .translate(let x, let y):
                    transform = transform.translatedBy(x: x, y: -y)

                case .blur:
                    preconditionFailure("Not reachable")
                    break
                }

                let tranformedImage = UIGraphicsImageRenderer(size: imageBounds.size).image { context in
                    context.cgContext.concatenate(transform)
                    context.cgContext.draw(current, in: imageBounds)
                }

                outputImage = tranformedImage.cgImage!
            }

            let outputImageSize = CGSize(width: outputImage.width, height: outputImage.height)
            let scaledRect = scaleRectangle(ofSize: outputImageSize, in: imageBounds)

            let renderedImage = UIGraphicsImageRenderer(size: imageSize).image { context in
                UIColor.white.setFill()
                context.fill(imageBounds)
                context.cgContext.translateBy(x: 0, y: needsFlip ? imageBounds.size.height : 0)
                context.cgContext.scaleBy(x: 1, y: needsFlip ? -1 : 1)
                let outputImageRect = scaledRect
                context.cgContext.draw(outputImage, in: outputImageRect)
            }

            current = renderedImage.cgImage!

            DispatchQueue.main.async {
                self.delegate?.augmentationSession(self, didCreateImage: renderedImage)
            }

        }

        DispatchQueue.main.async {
            self.delegate?.augmentationSessionDidFinish(self)
        }

    }

    func scaleRectangle(ofSize size: CGSize, in rect: CGRect) -> CGRect {

        let imageWidth = size.width
        let imageHeight = size.height
        let containerWidth = rect.size.width
        let containerHeight = rect.size.height

        // If the image is the same size as the container, return the container unscaled
        if (imageWidth == containerWidth) && (imageHeight == containerHeight) {
            return rect
        }

        // Downscale the image to fit inside the container if needed

        let scale: CGFloat
        let scaleX = containerWidth / imageWidth
        let scaleY = containerHeight / imageHeight

        if (imageWidth > containerWidth) || (imageHeight > containerHeight) {
            scale = min(scaleX, scaleY)
        } else {
            scale = 1
        }

        let adaptedWidth = imageWidth * scale
        let adaptedHeight = imageHeight * scale

        // Center the image in the parent container

        var adaptedRect = CGRect(origin: .zero, size: CGSize(width: adaptedWidth, height: adaptedHeight))
        adaptedRect.origin.x = rect.origin.x + ((containerWidth - adaptedWidth) / 2)
        adaptedRect.origin.y = rect.origin.y + ((containerHeight - adaptedHeight) / 2)

        return adaptedRect

    }

}
