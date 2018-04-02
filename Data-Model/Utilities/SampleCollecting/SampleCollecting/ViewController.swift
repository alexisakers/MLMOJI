//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit
import MobileCoreServices

/**
 * The view controller that records the samples for data labels.
 */

class ViewController: UIViewController {

    /**
     * Possible states for sample collection.
     */

    enum State {
        case idle
        case pendingUserInput(UUID)
        case pendingUserConfirmation(UUID)
        case pendingNewRequest
    }

    /// The active session.
    let session = try! Session()

    /// The state of sample collection.
    private var state: State = .idle {
        didSet {
            refreshInterfaceForUpdatedState()
        }
    }


    // MARK: - Views

    private let currentTitleLabel = UILabel()
    private let paper = Paper()
    private let submitButton = UIButton()
    private let stackView = UIStackView()
    private let contributionsLabel = UILabel()


    // MARK: - UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createContraints()
        view.backgroundColor = UIColor.groupTableViewBackground

        session.delegate = self
        session.start()
    }

    /**
     * Creates the views to display on the data collection screen.
     */

    private func createViews() {

        currentTitleLabel.adjustsFontSizeToFitWidth = true
        currentTitleLabel.textAlignment = .center
        currentTitleLabel.font = UIFont.systemFont(ofSize: 100)

        contributionsLabel.numberOfLines = 0
        contributionsLabel.textAlignment = .center
        contributionsLabel.font = UIFont.systemFont(ofSize: 24)

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
        view.addSubview(contributionsLabel)

        refreshContributionsLabel()
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

        contributionsLabel.translatesAutoresizingMaskIntoConstraints = false
        contributionsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        contributionsLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 16).isActive = true
        contributionsLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -16).isActive = true

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
     * Refreshes the number of contributions for each trained label.
     */

    private func refreshContributionsLabel() {

        let labels = session.contributions.map { label, count in
            return "\(label.emojiValue)\u{a0}\(count)"
        }

        contributionsLabel.text = labels.joined(separator: "\u{a0}\u{a0}•  ")

    }

    /**
     * Refreshes the UI when the state changes.
     */

    private func refreshInterfaceForUpdatedState() {

        switch state {
        case .idle:
            stackView.isHidden = true
        case .pendingUserInput:
            submitButton.isEnabled = false
            paper.isUserInteractionEnabled = true
            stackView.isHidden = false
            stackView.alpha = 1
        case .pendingUserConfirmation:
            submitButton.isEnabled = true
        case .pendingNewRequest:
            stackView.alpha = 0.5
        }

    }

    /**
     * Attempts to save the skecth from the paper into the session.
     */

    @objc private func submitSketch() {

        guard case let .pendingUserConfirmation(requestID) = state else {
            return
        }

        state = .pendingNewRequest
        let exporter = BitmapPaperExporter(size: session.sampleSize, scale: 1, fileType: kUTTypeJPEG)

        do {

            let jpgSample = try paper.export(with: exporter)
            try session.completeRequest(withID: requestID, sample: jpgSample)
            paper.clear()

        } catch {

            let alert = UIAlertController(title: "Could not save sample",
                                          message: (error as NSError).localizedDescription,
                                          preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)

            present(alert, animated: true) {
                self.paper.clear()
            }

        }

    }

}

// MARK: - SessionDelegate + PaperDelegate

extension ViewController: SessionDelegate, PaperDelegate {

    func sessionDidRequestSample(for label: Class, requestID: UUID) {
        currentTitleLabel.text = label.emojiValue
        state = .pendingUserInput(requestID)
    }

    func sessionDidAddContribution() {
        refreshContributionsLabel()
    }

    func paperDidStartDrawingStroke(_ paper: Paper) {
        // no-op
    }

    func paperDidFinishDrawingStroke(_ paper: Paper) {
        guard case let .pendingUserInput(requestID) = state else {
            return
        }

        state = .pendingUserConfirmation(requestID)
    }

}
