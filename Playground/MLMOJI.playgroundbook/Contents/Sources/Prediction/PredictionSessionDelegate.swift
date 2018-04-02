//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import Foundation

/**
 * An object that receives notifications from a prediction session.
 */

public protocol PredictionSessionDelegate: class {

    /**
     * The session has finished predicting the emoji for the current buffer.
     *
     * Always called on the main thread.
     */

    func predictionSession(_ session: PredictionSession, didUpdatePrediction prediction: EmojiPrediction)

    /**
     * The session failed to provide a prediction for the current buffer, and returned an error.
     *
     * Always called on the main thread.
     */

    func predictionSession(_ session: PredictionSession, didFailToProvidePredictionWith error: NSError)

}
