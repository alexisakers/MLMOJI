//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import Foundation

/**
 * The result of emoji classification.
 */

public class EmojiPrediction {

    let output: EmojiSketchesOutput

    init(output: EmojiSketchesOutput) {
        self.output = output
    }

    // MARK: - Wrappers

    /// The predicted class.
    public var classLabel: String {
        return output.classLabel
    }

    /// The predicted percentage for each class in the `Class` enum.
    public var predictions: [String: Double] {
        return output.final_result__0
    }

}
