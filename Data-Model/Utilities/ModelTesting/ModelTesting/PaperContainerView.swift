//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

class PaperContainerView: UIView {

    let paper: Paper

    init(paper: Paper) {
        self.paper = paper
        super.init(frame: .zero)
        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        self.paper = Paper()
        super.init(coder: aDecoder)
        createConstraints()
    }

    private func createConstraints() {
        addSubview(paper)
        paper.translatesAutoresizingMaskIntoConstraints = false
        paper.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        paper.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        paper.widthAnchor.constraint(equalToConstant: 300).isActive = true
        paper.heightAnchor.constraint(equalToConstant: 300).isActive = true

        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 300)
    }

}
