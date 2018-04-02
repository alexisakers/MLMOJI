//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * A collection view cell that displays an image.
 */

class ImageCollectionViewCell: UICollectionViewCell {

    /// The image view that displays the contents of the cell.
    private let imageView = UIImageView()

    // MARK: - Initializtion

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }

    /**
     * Configures the subviews of the cell.
     */

    private func configureViews() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.pinEdges(to: self)
    }

    // MARK: - Changing the Contents

    /**
     * Configures the cell to display the specified image.
     */

    func configure(image: UIImage) {
        self.imageView.image = image
    }

    override func prepareForReuse() {
        imageView.image = nil
    }

}
