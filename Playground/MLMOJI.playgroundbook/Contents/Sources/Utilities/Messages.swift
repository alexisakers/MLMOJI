//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import Foundation
import PlaygroundSupport

/**
 * The types of messages sent to the playground.
 */

public enum MessageType {

    /// The message describes an event.
    public static let event: String = "Event"
}

/**
 * The events that can happen in the app.
 */

public enum Event: String {

    /// The plaground page requested that the predictions be started.
    case startPredictions = "StartPredictions"

}

extension PlaygroundRemoteLiveViewProxy {

    /**
     * Sends an event to the proxy.
     */

    public func sendEvent(_ event: Event) {
        self.send(.dictionary([MessageType.event: PlaygroundValue.string(event.rawValue)]))
    }

}
