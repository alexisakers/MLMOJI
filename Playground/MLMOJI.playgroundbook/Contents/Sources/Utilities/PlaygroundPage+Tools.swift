//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import Foundation
import PlaygroundSupport

extension PlaygroundPage {

    /**
     * The object that receives message from the playground page.
     */

    public var proxy: PlaygroundRemoteLiveViewProxy? {
        return liveView as? PlaygroundRemoteLiveViewProxy
    }

}
