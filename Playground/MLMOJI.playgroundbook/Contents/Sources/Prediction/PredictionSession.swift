//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import Foundation
import CoreVideo

/**
 * Provides Core ML predictions for the EmojiSketches model.
 */

public class PredictionSession {

    /// The delegate to notify with updates.
    public weak var delegate: PredictionSessionDelegate? = nil

    /// The size of input images.
    public let inputSize = CGSize(width: 224, height: 224)

    /// The emoji prediction model.
    private let model: EmojiSketches

    /// The operation queue where operations will be executed.
    private let workQueue = DispatchQueue(label: "PredictionManager", qos: .userInitiated)

    /**
     * Creates a new session.
     */

    public init() {
        let url = Bundle.main.url(forResource: "EmojiSketches", withExtension: "mlmodelc")!
        model = try! EmojiSketches(contentsOf: url)
    }

    // MARK: - Getting Predictions

    /**
     * Requests a prediction for the specified image buffer. The results will be provided
     * to the session's delegate when available.
     */

    public func requestPrediction(for buffer: CVPixelBuffer) {

        let predictionWorkItem = DispatchWorkItem {

            do {
                let output = try self.model.prediction(input__0: buffer)
                let prediction = EmojiPrediction(output: output)
                DispatchQueue.main.async {
                    self.delegate?.predictionSession(self, didUpdatePrediction: prediction)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.predictionSession(self, didFailToProvidePredictionWith: error as NSError)
                }
            }

        }

        workQueue.async(execute: predictionWorkItem)

    }

}
