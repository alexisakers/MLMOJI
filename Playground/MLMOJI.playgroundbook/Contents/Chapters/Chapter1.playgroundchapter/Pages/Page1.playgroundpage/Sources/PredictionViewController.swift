//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * A view controller that displays a predictive keyboard and the results interface.
 */

public class PredictionViewController: UIViewController {

    /// The session that will handle predictions.
    let session = PredictionSession()

    /// Whether the keyboard is started.
    private(set) var startedPredictions: Bool = false

    /// The layout guide of the container.
    public var containerLayoutGuide: UILayoutGuide!

    // MARK: - UI Properties

    /// The paper where the user will draw.
    let paper = Paper()

    /// The view that displays the results.
    let resultsContainer = PredictionResultsContainer()

    /// The view containing the paper.
    let keyboardContainer = UIView()

    /// The button to clear the contents of the canvas.
    let clearButton = UIButton(type: .system)

    // MARK: - Initialization

    override public func loadView() {
        super.loadView()

        // Configure the keyboard container
        keyboardContainer.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8352941176, blue: 0.8588235294, alpha: 1)

        // Configure the paper
        paper.backgroundColor = .white
        paper.isUserInteractionEnabled = false

        // Configure the clear button
        let clearIcon = UIImage(named: "KeyboardClear")!.withRenderingMode(.alwaysTemplate)
        clearButton.setImage(clearIcon, for: .normal)
        clearButton.adjustsImageWhenHighlighted = true
        clearButton.isEnabled = false
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)

        // Configure the session
        session.delegate = self

    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resultsContainer.prepareForDisplay()
    }

    /// Configures the Auto Layout constraints of the view hierarchy.
    public func configureConstraints() {

        let keyboardSize: CGFloat = 250

        // Add the keyboard container and move it outside of the screen

        view.addSubview(keyboardContainer)
        keyboardContainer.translatesAutoresizingMaskIntoConstraints = false
        keyboardContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        keyboardContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        keyboardContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        keyboardContainer.transform = CGAffineTransform(translationX: 0, y: keyboardSize + 150)
        resultsContainer.stackView.transform = CGAffineTransform(translationX: 0, y: 150)

        // Add the paper
        keyboardContainer.addSubview(paper)
        paper.translatesAutoresizingMaskIntoConstraints = false
        paper.bottomAnchor.constraint(equalTo: containerLayoutGuide.bottomAnchor).isActive = true
        paper.centerXAnchor.constraint(equalTo: containerLayoutGuide.centerXAnchor).isActive = true

        // Add the undo button
        keyboardContainer.addSubview(clearButton)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.topAnchor.constraint(equalTo: keyboardContainer.topAnchor, constant: 16).isActive = true
        clearButton.trailingAnchor.constraint(equalTo: keyboardContainer.trailingAnchor, constant: -16).isActive = true

        // Constrain the size of the keyboard
        paper.heightAnchor.constraint(equalToConstant: keyboardSize).isActive = true
        paper.widthAnchor.constraint(equalToConstant: keyboardSize).isActive = true
        keyboardContainer.topAnchor.constraint(equalTo: paper.topAnchor).isActive = true

        // Add the results container
        view.addSubview(resultsContainer)
        resultsContainer.translatesAutoresizingMaskIntoConstraints = false
        resultsContainer.leadingAnchor.constraint(equalTo: containerLayoutGuide.leadingAnchor).isActive = true
        resultsContainer.trailingAnchor.constraint(equalTo: containerLayoutGuide.trailingAnchor).isActive = true
        resultsContainer.topAnchor.constraint(equalTo: containerLayoutGuide.topAnchor, constant: 16).isActive = true
        resultsContainer.bottomAnchor.constraint(equalTo: keyboardContainer.topAnchor, constant: -16).isActive = true

    }

    // MARK: - Interacting with the Paper

    /**
     * Starts the predictive keyboard.
     */

    func startPredictions() {

        paper.delegate = self
        paper.isUserInteractionEnabled = true
        paper.becomeFirstResponder()

        clearCanvas()

        let curve = UIViewAnimationCurve(rawValue: 7)!

        // Move the keyboard on the screen

        guard !startedPredictions else {
            return
        }

        var animations = resultsContainer.startPredictions()

        let showKeyboard = Animation(type: .property(0.35, curve)) {
            self.resultsContainer.stackView.transform = .identity
            self.keyboardContainer.transform = .identity
        }

        animations.append(showKeyboard)
        view.enqueueChanges(animations)

        startedPredictions = true

    }

    /**
     * Clears the canvas and resets the state of the prediction engine.
     */

    @objc private func clearCanvas() {
        paper.clear()
        resultsContainer.clear()
        clearButton.isEnabled = false
        resultsContainer.state = startedPredictions ? .startedPredictions : .displayed
    }

}

// MARK: - PaperDelegate

extension PredictionViewController: PaperDelegate {

    /**
     * When the user starts drawing, notify the results view.
     */

    public func paperDidStartDrawingStroke(_ paper: Paper) {
        resultsContainer.startDrawing()
    }

    /**
     * When a new stroke is added, request a new prediction.
     */

    public func paperDidFinishDrawingStroke(_ paper: Paper) {

        clearButton.isEnabled = true

        let exporter = CVPixelBufferExporter(size: session.inputSize, scale: 1)

        do {
            let imageBuffer = try paper.export(with: exporter)
            session.requestPrediction(for: imageBuffer)
        } catch {
            handleError(error)
        }

    }

}

extension PredictionViewController: PredictionSessionDelegate {

    public func predictionSession(_ session: PredictionSession, didUpdatePrediction prediction: EmojiPrediction) {
        resultsContainer.handle(result: prediction)
    }

    public func predictionSession(_ session: PredictionSession, didFailToProvidePredictionWith error: NSError) {
        handleError(error)
    }

    /**
     * Handles a prediction error.
     */

    private func handleError(_ error: Error) {

        let alert = UIAlertController(title: "Could not recognize emoji",
                                      message: (error as NSError).localizedDescription,
                                      preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .cancel) { _ in
            self.clearCanvas()
        }

        alert.addAction(ok)
        present(alert, animated: true, completion: nil)

    }

}
