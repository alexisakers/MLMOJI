//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit
import PlaygroundSupport

extension PredictionViewController: PlaygroundContainable {}

/**
 * Displays a prediction view controller in the safe are, and handles incoming messages.
 */

public class PlaygroundPredictionViewController: PlaygroundViewController<PredictionViewController>, PlaygroundLiveViewMessageHandler {

    public convenience init() {
        let vc = PredictionViewController()
        self.init(child: vc)
    }

    public func receive(_ message: PlaygroundValue) {

        guard case let .dictionary(dict) = message else { return }
        guard case let .string(eventName)? = dict[MessageType.event] else { return }

        if eventName == Event.startPredictions.rawValue {
            child.startPredictions()
        }

    }

}
