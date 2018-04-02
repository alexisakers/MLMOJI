//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * An object that receives information about the paper.
 */

public protocol PaperDelegate: class {

    /**
     * Called when the paper starts drawing a stroke.
     */

    func paperDidStartDrawingStroke(_ paper: Paper)

    /**
     * Called when the paper did finish drawing and flattening a stroke.
     */

    func paperDidFinishDrawingStroke(_ paper: Paper)

}

/**
 * A view that renders strokes based on touches.
 */

public class Paper: UIView {

    /// The object that receives updates about the paper.
    public weak var delegate: PaperDelegate? = nil

    // MARK: - Strokes

    /// The currently active stroke.
    private var currentStroke: [CGPoint]?

    /// The image containing the previously drawn strokes.
    private var strokesBuffer: UIImage?

    /// The color of the strokes.
    private let strokeColor: UIColor = .black

    /// The size of the brush.
    private let brushSize: CGFloat = 5


    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        // Redraw the contents of the paper when the screen changes.
        self.contentMode = .redraw
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Redraw the contents of the paper when the screen changes.
        self.contentMode = .redraw
    }

}

// MARK: - Drawing

extension Paper {

    /**
     * Draws the contents of the paper on the screen.
     */

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        if let buffer = strokesBuffer {

            // Scale the image if needed when we draw it for the first time
            if rect == bounds {
                let container = scaleRectangle(ofSize: buffer.size, in: rect)
                buffer.draw(in: container)
            } else {
                buffer.draw(at: .zero)
            }

        }

        // Draw the current unfinished stroke
        if let stroke = currentStroke {
            draw(stroke, in: context)
        }

    }

    /**
     * Draws a set of points.
     */

    private func draw(_ stroke: [CGPoint], in context: CGContext) {

        guard let firstPoint = stroke.first else {
            return
        }

        context.setFillColor(strokeColor.cgColor)
        context.setStrokeColor(strokeColor.cgColor)

        // If there is only one point, draw a dot.
        if stroke.count == 1 {
            context.fillEllipse(in: boundingRect(around: firstPoint))
            return
        }

        // If there are multiple points, join them with a set of strokes
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineWidth = brushSize

        path.move(to: stroke.first!)

        for point in stroke.dropFirst() {
            path.addLine(to: point)
        }

        path.stroke()

    }

    /**
     * Draws the current stroke on top of the buffer image, and updates the buffer image to
     * include the new stroke.
     */

    private func flatten(in renderer: UIGraphicsImageRenderer, bounds: CGRect) -> UIImage {

        // Draw the image and the current stroke in the context of the screen

        return renderer.image { context in

            UIColor.white.setFill()
            context.fill(bounds)

            if let bufferImage = strokesBuffer {
                let container = scaleRectangle(ofSize: bufferImage.size, in: bounds)
                bufferImage.draw(in: container)
            }

            if let stroke = currentStroke {
                draw(stroke, in: context.cgContext)
            }

        }

    }

}

// MARK: - Calculations

private extension Paper {

    /**
     * Calculates a point between the previous point and the new one to achieve a smoother line.
     */

    func continuousPoint(at location: CGPoint) -> CGPoint {
        let factor: CGFloat = 0.35
        let previous = currentStroke!.last!
        return CGPoint(x: previous.x * (1 - factor) + location.x * factor,
                       y: previous.y * (1 - factor) + location.y * factor)
    }

    /**
     * Returns the bounding rectangle around the specified point.
     *
     * It is a rectangle where the point is the center, and whose size is the size of the brush.
     */

    func boundingRect(around point: CGPoint) -> CGRect {
        let inset = brushSize / 2
        return CGRect(x: point.x - inset, y: point.y - inset, width: brushSize, height: brushSize)
    }

    /**
     * Returns the bounding rectangle around the last `n` last point.
     */

    func boundingRect(aroundLast n: Int) -> CGRect {
        guard let lastPoints = currentStroke?.suffix(n) else {
            return .zero
        }

        var minX = 0.0, minY = 0.0, maxX = 0.0, maxY = 0.0

        for point in lastPoints {
            minX = min(Double(point.x), minX)
            minY = min(Double(point.y), minY)
            maxX = max(Double(point.x), maxX)
            maxY = max(Double(point.y), maxY)
        }

        let margins = Double(brushSize) * 2

        return CGRect(x: minX, y: minY, width: maxX - minX + margins, height: maxY - minY + margins)
            .insetBy(dx: -brushSize, dy: -brushSize)
    }

    /**
     * Downscales the image for the container if needed.
     */

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

// MARK: - Touch Handling

extension Paper {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let location = touches.first?.location(in: self) else {
            return
        }

        self.currentStroke = [location]

        // Draw the initial point.
        let affectedRect = boundingRect(around: location)
        setNeedsDisplay(affectedRect)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let firstTouch = touches.first else {
            return
        }

        // Handle touch aggregation

        guard let coalescedTouches = event?.coalescedTouches(for: firstTouch) else {
            return
        }

        for touch in coalescedTouches {
            let location = touch.location(in: self)
            let point = continuousPoint(at: location)
            currentStroke?.append(point)
        }

        delegate?.paperDidStartDrawingStroke(self)

        // Redraw the points that affect the curve
        let affectedRect = boundingRect(aroundLast: coalescedTouches.count + 2)
        setNeedsDisplay(affectedRect)

    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        // Flatten the stroke so that it can be scaled as appropriate if the screen size changes
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        strokesBuffer = flatten(in: renderer, bounds: bounds)

        // Redraw with the buffer
        currentStroke = nil
        delegate?.paperDidFinishDrawingStroke(self)
        setNeedsDisplay()
    }

    public override var canBecomeFirstResponder: Bool {
        return true
    }

}

// MARK: - Interacting with the contents

extension Paper {

    /**
     * Clears the contents of the screen.
     */

    public func clear() {
        strokesBuffer = nil
        setNeedsDisplay()
    }

    /**
     * Exports the contents of the paper as an image.
     *
     * - parameter size: The size of the exported image.
     */

    public func exportImage(size: CGSize) -> CGImage {

        let bounds = CGRect(origin: .zero, size: size)

        let format = UIGraphicsImageRendererFormat(for: traitCollection)
        format.opaque = true
        format.prefersExtendedRange = false
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        let finalImage = flatten(in: renderer, bounds: bounds)

        return finalImage.cgImage!

    }

    /**
     * Exports the contents of the canvas using the specified exporter.
     *
     * The strokes will be drawn on a white opaque background. The image will be scaled to
     * fit inside the exporter's container bounds, using its `size` property.
     */

    public func export<T: PaperExporter>(with exporter: T) throws -> T.Output {
        let exportedImage = exportImage(size: exporter.size)
        return try exporter.exportPaper(contents: exportedImage)
    }

}
