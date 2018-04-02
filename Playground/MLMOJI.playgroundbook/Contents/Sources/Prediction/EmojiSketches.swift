//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//
//  This file was automatically generated and should not be edited.
//

import CoreML

/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class EmojiSketchesInput : MLFeatureProvider {

    /// input__0 as color (kCVPixelFormatType_32BGRA) image buffer, 224 pixels wide by 224 pixels high
    var input__0: CVPixelBuffer

    var featureNames: Set<String> {
        get {
            return ["input__0"]
        }
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "input__0") {
            return MLFeatureValue(pixelBuffer: input__0)
        }
        return nil
    }

    init(input__0: CVPixelBuffer) {
        self.input__0 = input__0
    }
}

/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class EmojiSketchesOutput : MLFeatureProvider {

    /// final_result__0 as dictionary of strings to doubles
    public let final_result__0: [String : Double]

    /// classLabel as string value
    public let classLabel: String

    public var featureNames: Set<String> {
        get {
            return ["final_result__0", "classLabel"]
        }
    }

    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "final_result__0") {
            return try! MLFeatureValue(dictionary: final_result__0 as [NSObject : NSNumber])
        }
        if (featureName == "classLabel") {
            return MLFeatureValue(string: classLabel)
        }
        return nil
    }

    public init(final_result__0: [String : Double], classLabel: String) {
        self.final_result__0 = final_result__0
        self.classLabel = classLabel
    }
}

/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class EmojiSketches {
    var model: MLModel

    /**
     Construct a model with explicit path to mlmodel file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        let bundle = Bundle(for: EmojiSketches.self)
        let assetPath = bundle.url(forResource: "EmojiSketches", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }

    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as EmojiSketchesInput
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as EmojiSketchesOutput
     */
    func prediction(input: EmojiSketchesInput) throws -> EmojiSketchesOutput {
        let outFeatures = try model.prediction(from: input)
        let result = EmojiSketchesOutput(final_result__0: outFeatures.featureValue(for: "final_result__0")!.dictionaryValue as! [String : Double], classLabel: outFeatures.featureValue(for: "classLabel")!.stringValue)
        return result
    }

    /**
     Make a prediction using the convenience interface
     - parameters:
     - input__0 as color (kCVPixelFormatType_32BGRA) image buffer, 224 pixels wide by 224 pixels high
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as EmojiSketchesOutput
     */
    func prediction(input__0: CVPixelBuffer) throws -> EmojiSketchesOutput {
        let input_ = EmojiSketchesInput(input__0: input__0)
        return try self.prediction(input: input_)
    }
}
