//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

extension UIView {

    /**
     * Pins the edges of the reciever to those of the specified view.
     */

    public func pinEdges(to container: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
    }

}
