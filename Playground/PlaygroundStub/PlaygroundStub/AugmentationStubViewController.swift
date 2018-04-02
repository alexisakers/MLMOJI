//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

class AugmentationStubViewController: UIViewController {

    let filters: [AugmentationFilter] = [
        .translate(-15, 69), .rotate(45), .rotate(18), .scale(150), .blur
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let augmentationVC = AugmentViewController(filters: filters)
        augmentationVC.containerLayoutGuide = view.safeAreaLayoutGuide

        addChildViewController(augmentationVC)
        view.addSubview(augmentationVC.view)
        augmentationVC.configureConstraints()

        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "ArtificalBackground"))
        augmentationVC.view.pinEdges(to: self.view)
    }

}
