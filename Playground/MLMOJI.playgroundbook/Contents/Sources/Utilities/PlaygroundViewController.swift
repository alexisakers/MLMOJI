//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit
import PlaygroundSupport

// MARK: PlaygroundContainable

/**
 * A view controller that can be contained inside a playground's safe area.
 */

public protocol PlaygroundContainable: class {
    var containerLayoutGuide: UILayoutGuide! { get set }
    func configureConstraints()
}

// MARK: - PlaygroundViewController

/**
 * A view controller that displays a child view controller within the playground safe area.
 */

open class PlaygroundViewController<T: UIViewController & PlaygroundContainable>: UIViewController, PlaygroundLiveViewSafeAreaContainer {

    /// The child view controller displayed in the playground.
    public let child: T

    // MARK: Initialization

    public init(child: T) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) was not implemented.")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        child.containerLayoutGuide = liveViewSafeAreaGuide
        addChildViewController(child)
        view.addSubview(child.view)
        child.configureConstraints()
        child.view.pinEdges(to: view)
        child.didMove(toParentViewController: self)
    }

}
