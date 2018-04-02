//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * The classes that the image classifier recognizes.
 */

public enum Class: String {

    case laugh
    case smile
    case heart
    case checkmark
    case croissant
    case sun
    case cloud

    /// An array containing all the class labels.
    public static var allLabels: [Class] {
        return [.smile, .laugh, .sun, .checkmark, .croissant, .heart, .cloud]
    }

    /// The emoji representation of this label.
    public var emojiValue: String {
        switch self {
        case .laugh: return "😂"
        case .smile: return "😊"
        case .heart: return "❤️"
        case .checkmark: return "✔️"
        case .croissant: return "🥐"
        case .sun: return "☀️"
        case .cloud: return "☁️"
        }
    }

    /// The color to show for prediction bars.
    public var highlightColor: UIColor {
        switch self {
        case .laugh: return #colorLiteral(red: 0.8274509804, green: 0.3333333333, blue: 0.3607843137, alpha: 1)
        case .smile: return #colorLiteral(red: 0.9568627451, green: 0.5529411765, blue: 0.2274509804, alpha: 1)
        case .heart: return #colorLiteral(red: 0.9921568627, green: 0.7803921569, blue: 0.3254901961, alpha: 1)
        case .checkmark: return #colorLiteral(red: 0.4392156863, green: 0.737254902, blue: 0.3254901961, alpha: 1)
        case .croissant: return #colorLiteral(red: 0.1411764706, green: 0.6117647059, blue: 0.8352941176, alpha: 1)
        case .sun: return #colorLiteral(red: 0.2196078431, green: 0.08235294118, blue: 0.5725490196, alpha: 1)
        case .cloud: return #colorLiteral(red: 0.5058823529, green: 0.1215686275, blue: 0.537254902, alpha: 1)
        }
    }

}
