//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit
import PlaygroundSupport

let label = UILabel()
label.text = "🎉"
label.font = UIFont.systemFont(ofSize: 123)
label.textAlignment = .center
label.baselineAdjustment = .alignCenters
label.numberOfLines = 1

let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
pulseAnimation.duration = 3.0
pulseAnimation.toValue = NSNumber(value: 0.8)
pulseAnimation.repeatCount = Float.infinity
pulseAnimation.autoreverses = true

label.layer.add(pulseAnimation, forKey: nil)
PlaygroundPage.current.liveView = label
