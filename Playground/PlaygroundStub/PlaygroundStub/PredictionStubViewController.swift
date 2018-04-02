//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

class PredictionStubViewController: UIViewController {

    var predictionVC: PredictionViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        predictionVC = PredictionViewController()
        predictionVC.containerLayoutGuide = view.safeAreaLayoutGuide

        addChildViewController(predictionVC)
        view.addSubview(predictionVC.view)
        predictionVC.configureConstraints()

        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "ArtificalBackground"))
        predictionVC.view.pinEdges(to: self.view)

        predictionVC.didMove(toParentViewController: self)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start Predictions", style: .plain, target: self, action: #selector(startButtonTapped))
    }

    @objc func startButtonTapped() {
        self.predictionVC.startPredictions()
    }

}
