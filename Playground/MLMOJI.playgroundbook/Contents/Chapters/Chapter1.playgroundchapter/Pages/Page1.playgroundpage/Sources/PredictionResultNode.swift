//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * A view that displays the prediction result for a single emojis.
 *
 * It has two states: waiting for prediction and expanded.
 */

class PredictionResultNode: UIView {

    /// The label that displays the emoji.
    let emojiLabel = UILabel()

    /// The label that displays the likeliness percentage.
    let percentageLabel = UILabel()

    /// The view that contains the percentage prediction.
    let percentageContainerView = UIView()

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
     * Configures the subviews appearance.
     */

    private func configureSubviews() {

        emojiLabel.font = UIFont.systemFont(ofSize: 40)
        emojiLabel.adjustsFontSizeToFitWidth = true
        emojiLabel.textAlignment = .center
        emojiLabel.baselineAdjustment = .alignCenters

        percentageLabel.font = UIFont.systemFont(ofSize: 55, weight: .bold)
        percentageLabel.textColor = .white
        percentageLabel.textAlignment = .center
        percentageLabel.adjustsFontSizeToFitWidth = true
        percentageLabel.baselineAdjustment = .alignCenters

        percentageContainerView.layer.cornerRadius = 12
        percentageContainerView.addSubview(emojiLabel)
        percentageContainerView.addSubview(percentageLabel)

        addSubview(percentageContainerView)

    }

    /**
     * Creates the constraints for the given view.
     */

    private func configureConstraints() {

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageContainerView.translatesAutoresizingMaskIntoConstraints = false

        emojiLabel.leadingAnchor.constraint(equalTo: percentageContainerView.leadingAnchor, constant: 8).isActive = true
        emojiLabel.topAnchor.constraint(equalTo: percentageContainerView.topAnchor, constant: 8).isActive = true
        emojiLabel.bottomAnchor.constraint(equalTo: percentageContainerView.bottomAnchor, constant: -10).isActive = true
        emojiLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        percentageLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8).isActive = true
        percentageLabel.trailingAnchor.constraint(equalTo: percentageContainerView.trailingAnchor, constant: -8).isActive = true
        percentageLabel.centerYAnchor.constraint(equalTo: percentageContainerView.centerYAnchor).isActive = true
        percentageLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        percentageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        percentageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        percentageContainerView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        percentageContainerView.heightAnchor.constraint(equalToConstant: 55).isActive = true

        trailingAnchor.constraint(equalTo: percentageContainerView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: percentageContainerView.bottomAnchor).isActive = true

    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 150, height: 55)
    }

    // MARK: - Changing the Data

    /**
     * Displays the given prediction output.
     */

    func display(output: Double, for predictionClass: Class) {

        emojiLabel.text = predictionClass.emojiValue
        percentageLabel.text = String(format: "%.2f", output * 100) + "%"

        if output >= 0.2 {
            percentageLabel.font = UIFont.systemFont(ofSize: 55, weight: .bold)
            percentageContainerView.backgroundColor = predictionClass.highlightColor
        } else {
            percentageLabel.font = UIFont.systemFont(ofSize: 22, weight: .light)
            percentageContainerView.backgroundColor = predictionClass.highlightColor.withAlphaComponent(0.5)
        }

    }

    /**
     * Resets the result node.
     */

    func reset() {
        emojiLabel.text =  nil
        percentageLabel.text = nil
        percentageContainerView.backgroundColor = nil
    }

}
