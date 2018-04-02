//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit

/**
 * The types of animation that can be queued.
 */

public enum AnimationType {

    /// A UIView transition of the specified duration and options.
    case transition(Double, UIViewAnimationOptions)

    /// A UIView property animation of the specified duration and curve.
    case property(Double, UIViewAnimationCurve)

    /// A change that is not animated.
    case notAnimated

}

/**
 * Describes a view change.
 */

public class Animation {

    /// The changes to send to the view.
    let changes: () -> Void

    /// The type of animation to perform.
    let type: AnimationType

    public init(type: AnimationType, changes: @escaping () -> Void) {
        self.changes = changes
        self.type = type
    }

}

// MARK: - Enqueuing Changes

extension UIView {

    /**
     * Enqueues an animation.
     */

    public func enqueueChanges(animation: AnimationType, changes: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {

        setNeedsLayout()

        let layoutCompletion: (Bool) -> Void = {
            self.setNeedsLayout()
            completion?($0)
        }

        switch animation {
        case .notAnimated:
            changes()
            layoutCompletion(true)

        case let .property(duration, curve):
            let animator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: changes)
            animator.addCompletion { layoutCompletion($0 == .end) }
            animator.startAnimation()

        case let .transition(duration, options):
            UIView.transition(with: self, duration: duration, options: options, animations: changes, completion: layoutCompletion)
        }

    }

    /**
     * Performs multiple animations one after the other.
     */

    public func enqueueChanges(_ animations: [Animation]) {

        guard let currentAnimation = animations.first else {
            return
        }

        let nextIndex = animations.index(after: animations.startIndex)

        enqueueChanges(animation: currentAnimation.type, changes: currentAnimation.changes) { finished in

            let next = Array<Animation>(animations.suffix(from: nextIndex))

            guard finished else {
                next.forEach { $0.changes() }
                return
            }

            self.enqueueChanges(next)

        }

    }

}
