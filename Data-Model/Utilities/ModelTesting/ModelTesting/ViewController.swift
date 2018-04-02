//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * The view controller that records the samples for data labels.
 */

class ViewController: UIViewController {

    /**
     * Possible states for sample collection.
     */

    enum State {
        case idle
        case drawing
        case recognized(String)
    }

    /// The state of sample collection.
    private var state: State = .idle {
        didSet {
            refreshInterfaceForUpdatedState()
        }
    }

    private var session = PredictionSession()


    // MARK: - Views

    private let currentTitleLabel = UILabel()
    private let paper = Paper()
    private let submitButton = UIButton()
    private let stackView = UIStackView()

    // MARK: - UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        
        createViews()
        createContraints()
        view.backgroundColor = UIColor.groupTableViewBackground
    }

    /**
     * Creates the views to display on the data collection screen.
     */

    private func createViews() {

        currentTitleLabel.adjustsFontSizeToFitWidth = true
        currentTitleLabel.textAlignment = .center
        currentTitleLabel.font = UIFont.systemFont(ofSize: 30)
        currentTitleLabel.numberOfLines = 0

        paper.backgroundColor = .white
        paper.isUserInteractionEnabled = false
        paper.delegate = self

        let paperContainer = PaperContainerView(paper: paper)

        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitle("Save", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let buttonBackgroundColor = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }

        submitButton.setBackgroundImage(buttonBackgroundColor, for: .normal)
        submitButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        submitButton.layer.cornerRadius = 12
        submitButton.clipsToBounds = true

        submitButton.addTarget(self, action: #selector(submitSketch), for: .touchUpInside)

        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.addArrangedSubview(currentTitleLabel)
        stackView.addArrangedSubview(paperContainer)
        stackView.addArrangedSubview(submitButton)

        view.addSubview(stackView)

        configureViews(isRegular: traitCollection.horizontalSizeClass == .regular)
        refreshInterfaceForUpdatedState()

    }

    /**
     * Creates the Auto Layout constraints for the view.
     */

    private func createContraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        submitButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
    }

    /**
     * Responds to size class changes.
     */

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureViews(isRegular: traitCollection.horizontalSizeClass == .regular)
    }

    /**
     * Configures the view for adaptive presentation.
     */

    private func configureViews(isRegular: Bool) {
        stackView.spacing = isRegular ? 64 : 32
    }

    // MARK: - Session


    /**
     * Refreshes the UI when the state changes.
     */

    private func refreshInterfaceForUpdatedState() {

        switch state {
        case .idle:
            submitButton.setTitle("Recognize", for: .normal)
            currentTitleLabel.isHidden = true
            submitButton.isEnabled = false
            paper.isUserInteractionEnabled = true
        case .drawing:
            submitButton.isEnabled = true
        case .recognized(let labels):
            paper.isUserInteractionEnabled = false
            submitButton.setTitle("Restart", for: .normal)
            currentTitleLabel.text = labels
            currentTitleLabel.isHidden = false
        }

    }

    /**
     * Attempts to save the skecth from the paper into the session.
     */

    @objc private func submitSketch() {

        switch state {
        case .idle:
            return
        case .recognized:
            paper.clear()
            state = .idle
            return
        case .drawing:
            break
        }

        let exporter = CVPixelBufferExporter(size: session.inputSize, scale: 1)

        do {
            let buffer = try paper.export(with: exporter)
            session.requestPrediction(for: buffer)
        } catch {
            handleError((error as NSError).localizedDescription)
        }

    }

}

// MARK: - PredictionSessionDelegate + PaperDelegate

extension ViewController: PredictionSessionDelegate {

    func predictionSession(_ session: PredictionSession, didUpdatePrediction prediction: EmojiSketchesOutput) {

        let top3: [String] = prediction.final_result__0.sorted { a, b in
            return a.value > b.value
        }.prefix(3).flatMap {
            guard let predictionClass = Class(rawValue: $0.key) else {
                handleError("Invalid class name '\($0.key)'")
                return nil
            }

            return "\(predictionClass.emojiValue) = \($0.value)"
        }

        state = .recognized(top3.joined(separator: "\n"))

    }

    func predictionSession(_ session: PredictionSession, didFailToProvidePredictionWith error: NSError) {
        handleError(error.localizedDescription)
    }

}

extension ViewController: PaperDelegate {

    func paperDidStartDrawingStroke(_ paper: Paper) {
        // no-op
    }

    func paperDidFinishDrawingStroke(_ paper: Paper) {
        guard case .idle = state else {
            return
        }

        state = .drawing
    }

}

// MARK: - Error Handling

extension ViewController {

    func handleError(_ description: String) {

        let alert = UIAlertController(title: "Could not recognize emoji",
                                      message: description,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.paper.clear()
        })

        alert.addAction(cancelAction)
        present(alert, animated: true)

    }

}
