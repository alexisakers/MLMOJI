//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

private let kPlaceholderFloatAnimation = "PredictionResultsContainer.PlaceholderFloat"
private let kStatusDraw = "🖌 Draw on the canvas below"
private let kStatusFailure = "😿 Could not guess the emoji"

/**
 * A view that displays the results of the prediction.
 */

class PredictionResultsContainer: UIView {

    enum State {
        case idle
        case displayed
        case startedPredictions
        case waitingInitialPrediction
        case predicted
        case noPrediction
    }

    /// The state of the results.
    var state: State = .idle

    // MARK: - Properties

    /// The main content stack view.
    let stackView = UIStackView()

    /// The lines displaying the placeholder result.
    private var placeholderLineStacks: [UIStackView] = []

    /// The view that contains the status placeholder.
    private let statusPlaceholderContainer = UIView()

    /// The placeholder to display status messages.
    private let statusPlaceholder = UILabel()

    /// The nodes that display the result of the prediction.
    private let resultNodes: [PredictionResultNode] = {
        return [PredictionResultNode(), PredictionResultNode(), PredictionResultNode()]
    }()

    private var small_left_trailing: NSLayoutConstraint?
    private var small_left_bottom: NSLayoutConstraint?
    private var small_middle_leading: NSLayoutConstraint?
    private var small_middle_bottom: NSLayoutConstraint?
    private var small_right_top: NSLayoutConstraint?
    private var small_right_centerX: NSLayoutConstraint?

    private var large_middle_centerX: NSLayoutConstraint?
    private var large_middle_centerY: NSLayoutConstraint?
    private var large_left_trailing: NSLayoutConstraint?
    private var large_left_centerY: NSLayoutConstraint?
    private var large_right_leading: NSLayoutConstraint?
    private var large_right_centerY: NSLayoutConstraint?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }

    /**
     * Configures the view's subviews.
     */

    private func configureSubviews() {

        // 1) Create the general stack

        stackView.axis = .vertical
        stackView.spacing = 55
        stackView.alignment = .center
        stackView.distribution = .fillEqually

        addSubview(stackView)

        // 2) Create the placeholder lines

        let allClasses = Class.allLabels
        let (numberOfLines, remainingEmojis) = allClasses.count.quotientAndRemainder(dividingBy: 4)

        // 2.1 - Create the lines

        for lineIndex in 0 ..< numberOfLines {

            let startIndex = allClasses.startIndex + (lineIndex * 4)
            let endIndex = startIndex + 4

            let stack = makePlaceholderLineStack(content: allClasses, startIndex: startIndex, endIndex: endIndex)
            placeholderLineStacks.append(stack)
            stackView.addArrangedSubview(stack)

        }

        // 2.2 - Create a line for the remaining classes

        let startIndex = allClasses.startIndex + (numberOfLines * 4)
        let endIndex = startIndex + remainingEmojis

        let stack = makePlaceholderLineStack(content: allClasses, startIndex: startIndex, endIndex: endIndex)
        placeholderLineStacks.append(stack)
        stackView.addArrangedSubview(stack)

        // 3) Create the result nodes

        for node in resultNodes {
            addSubview(node)
        }

        // 4) Create the status placeholder

        statusPlaceholder.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        statusPlaceholder.numberOfLines = 1
        statusPlaceholder.textColor = .black

        statusPlaceholderContainer.backgroundColor = .white
        statusPlaceholderContainer.layer.cornerRadius = 12
        statusPlaceholderContainer.alpha = 0

        statusPlaceholderContainer.addSubview(statusPlaceholder)
        addSubview(statusPlaceholderContainer)

    }

    /**
     * Creates a stack view that displays a line of elements.
     */

    private func makeLineStack() -> UIStackView {

        let stack = UIStackView()
        stack.spacing = 55
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.axis = .horizontal

        return stack

    }

    /**
     * Creates a placeholder line stack for the classes between the given indices.
     */

    private func makePlaceholderLineStack(content: [Class], startIndex: Int, endIndex: Int) -> UIStackView {

        let stack = makeLineStack()

        for classIndex in startIndex ..< endIndex {

            let predictionClass = content[classIndex]

            let floatingLabel = UILabel()
            floatingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 69, weight: .regular)
            floatingLabel.adjustsFontSizeToFitWidth = true
            floatingLabel.text = predictionClass.emojiValue

            stack.addArrangedSubview(floatingLabel)

        }

        return stack

    }

    /**
     * Configures the Auto Layout constraints
     */

    private func configureConstraints() {

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        statusPlaceholderContainer.translatesAutoresizingMaskIntoConstraints = false
        statusPlaceholderContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        statusPlaceholderContainer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        statusPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        statusPlaceholder.leadingAnchor.constraint(equalTo: statusPlaceholderContainer.leadingAnchor, constant: 10).isActive = true
        statusPlaceholder.topAnchor.constraint(equalTo: statusPlaceholderContainer.topAnchor, constant: 10).isActive = true
        statusPlaceholderContainer.trailingAnchor.constraint(equalTo: statusPlaceholder.trailingAnchor, constant: 15).isActive = true
        statusPlaceholderContainer.bottomAnchor.constraint(equalTo: statusPlaceholder.bottomAnchor, constant: 10).isActive = true

        // Result nodes

        let leftNode = resultNodes[0]
        let middleNode = resultNodes[1]
        let rightNode = resultNodes[2]

        leftNode.translatesAutoresizingMaskIntoConstraints = false
        middleNode.translatesAutoresizingMaskIntoConstraints = false
        rightNode.translatesAutoresizingMaskIntoConstraints = false

        // Compact width

        small_left_trailing = leftNode.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -25)
        small_left_bottom = leftNode.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -25)
        small_middle_leading = middleNode.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 25)
        small_middle_bottom = middleNode.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -25)
        small_right_top = rightNode.topAnchor.constraint(equalTo: centerYAnchor, constant: 25)
        small_right_centerX = rightNode.centerXAnchor.constraint(equalTo: centerXAnchor)

        large_middle_centerX = middleNode.centerXAnchor.constraint(equalTo: centerXAnchor)
        large_middle_centerY = middleNode.centerYAnchor.constraint(equalTo: centerYAnchor)
        large_left_trailing = leftNode.trailingAnchor.constraint(equalTo: middleNode.leadingAnchor, constant: -55)
        large_left_centerY = leftNode.centerYAnchor.constraint(equalTo: centerYAnchor)
        large_right_leading = rightNode.leadingAnchor.constraint(equalTo: middleNode.trailingAnchor, constant: 55)
        large_right_centerY = rightNode.centerYAnchor.constraint(equalTo: centerYAnchor)

        // Large Width

    }

    // MARK: - Animations

    /**
     * Adds the gravity floating animation to the placeholders.
     */

    private func floatPlaceholders() {

        for line in self.placeholderLineStacks.reversed() {

            for placeholder in line.arrangedSubviews {
                let rotateAnimation = makeGravityAnimation(for: placeholder)
                placeholder.layer.removeAnimation(forKey: kPlaceholderFloatAnimation)
                placeholder.layer.add(rotateAnimation, forKey: kPlaceholderFloatAnimation)
            }

        }

    }

    /**
     * Creates an animation that makes the layer rotate around a random orbit.
     */

    private func makeGravityAnimation(for placeholder: UIView) -> CAKeyframeAnimation {

        // Define the distance between the center of the layer and its roation orbit
        let radius: CGFloat = 7.5

        // Calculate a random angle to define the direction of the orbit and convert it to radians
        let angle = (CGFloat(arc4random_uniform(360 - 25 + 1) + 25)  * CGFloat.pi) / 180

        // Calculate a random rotation duration (between 4 and 6s)
        let duration = Double(arc4random_uniform(6 - 4 + 1) + 4)

        // Calculate the offset between the center of the layer and the edge of the orbit (thanks, trig!)
        let yOffset = sin(angle) * radius
        let xOffset = cos(angle) * radius

        // Calculate the path of the orbit

        let center = placeholder.center

        let rotationPoint = CGPoint(x: center.x - xOffset,
                                    y: center.y - yOffset)

        let minX = min(center.x, rotationPoint.x)
        let minY = min(center.y, rotationPoint.y)
        let maxX = max(center.x, rotationPoint.x)
        let maxY = max(center.y, rotationPoint.y)

        let size = max(maxX - minX, maxY - minY)

        let ovalRect = CGRect(x: minX, y: minY,
                              width: size, height:size)

        let ovalPath = UIBezierPath(ovalIn: ovalRect)

        // Create and return the animation

        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = ovalPath.cgPath
        animation.isCumulative = false
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.repeatCount = .infinity
        animation.duration = duration
        animation.calculationMode = kCAAnimationPaced

        return animation

    }

    /**
     * Creates the animations to display the placeholder status. The returned animations should
     * be enqueued as soon as possible.
     */

    private func displayStatusPlaceholder() -> [Animation] {

        var animations: [Animation] = []
        statusPlaceholderContainer.transform = CGAffineTransform(scaleX: 0, y: 0)

        let upscaleStatusPrompt = Animation(type: .property(0.4, .easeIn)) {
            self.statusPlaceholderContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.statusPlaceholderContainer.alpha = 0.69
        }

        let finalizeStatusPrompt = Animation(type: .property(0.2, .easeOut)) {
            self.statusPlaceholderContainer.transform = .identity
            self.statusPlaceholderContainer.alpha = 1
        }

        animations.append(upscaleStatusPrompt)
        animations.append(finalizeStatusPrompt)

        return animations

    }

    // MARK: - Interacting with the Results

    /**
     * Starts the result view.
     *
     * This method adds the gravity floating animation.
     */

    func prepareForDisplay() {
        state = .displayed
        floatPlaceholders()
        setNeedsLayout()
    }

    /**
     * Returns the animations to remove the placeholder and display the draw prompt.
     */

    func startPredictions() -> [Animation] {

        state = .startedPredictions

        var animations: [Animation] = []

        // Remove the placeholders

        for line in self.placeholderLineStacks.reversed() {

            let removePlaceholders = line.arrangedSubviews.reversed().map { placeholder in
                Animation(type: .property(0.25, .linear)) { placeholder.alpha = 0 }
            }

            animations.append(contentsOf: removePlaceholders)

        }

        // Hide the lines

        let hideLines = self.placeholderLineStacks.map { line in
            Animation(type: .notAnimated) { line.isHidden = true }
        }

        animations.append(contentsOf: hideLines)

        // Show the drawing prompt

        statusPlaceholder.text = kStatusDraw

        let statusOnAnimations = displayStatusPlaceholder()
        animations.append(contentsOf: statusOnAnimations)

        return animations

    }

    /**
     * Removes the state placeholder.
     */

    func startDrawing() {

        guard state == .startedPredictions else {
            return
        }

        state = .waitingInitialPrediction

        enqueueChanges(animation: .property(0.25, .linear), changes: {
            self.statusPlaceholderContainer.alpha = 0
        })

    }

    /**
     * Removes all the result nodes and displays the placeholders.
     */

    func clear() {

        enqueueChanges(animation: .transition(0.35, .transitionCrossDissolve), changes: {
            self.resultNodes.forEach({ $0.reset() })
        })

    }

    /**
     * Handles the output of a Core ML prediction.
     */

    func handle(result: EmojiPrediction) {

        state = .predicted

        // Get the result sorted by highest likeliness

        let sortedResuls = result.predictions.sorted {
            $0.value > $1.value
        }

        // Only display the first 3 results
        let top3 = sortedResuls.prefix(3)

        // If there are no predictions, return early

        if top3.count < 3 {
            handleNoPrediction()
            return
        }

        // Remove the status

        enqueueChanges(animation: .property(0.25, .linear), changes: {
            self.statusPlaceholderContainer.alpha = 0
        })

        // Update the elements

        for (prediction, node) in zip(top3, resultNodes) {

            guard let classLabel = Class(rawValue: prediction.key) else {
                continue
            }

            node.alpha = 1
            node.display(output: prediction.value, for: classLabel)

        }

    }

    /**
     * Handles the case where no predictions are found.
     */

    private func handleNoPrediction() {

        var animations: [Animation] = []

        statusPlaceholder.text = kStatusFailure
        let statusOnAnimations = displayStatusPlaceholder()
        animations.append(contentsOf: statusOnAnimations)

        if state == .predicted {

            let removeResults = Animation(type: .transition(0.35, .transitionCrossDissolve)) {
                self.resultNodes.forEach({ $0.reset() })
            }

            animations.append(removeResults)

        }

        state = .noPrediction
        enqueueChanges(animations)

    }

    // MARK: - Layout

    override func layoutSubviews() {

        if case .displayed = state {
            floatPlaceholders()
        }

        let isCompactWidth = frame.size.width < 624
        updateLayout(isCompact: isCompactWidth)

    }

    func updateLayout(isCompact: Bool) {

        small_left_trailing?.isActive = isCompact
        small_left_bottom?.isActive = isCompact
        small_middle_leading?.isActive = isCompact
        small_middle_bottom?.isActive = isCompact
        small_right_top?.isActive = isCompact
        small_right_centerX?.isActive = isCompact

        large_middle_centerX?.isActive = !isCompact
        large_middle_centerY?.isActive = !isCompact
        large_left_trailing?.isActive = !isCompact
        large_left_centerY?.isActive = !isCompact
        large_right_leading?.isActive = !isCompact
        large_right_centerY?.isActive = !isCompact

    }

}
