//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import Foundation
import UIKit

/**
 * The delegate of a session.
 */

protocol SessionDelegate: class {

    /**
     * The session did request a sample for the given label. Once you have the data, call
     * `session.completeRequest(withID:,sample:)` to provide the sample data.
     */

    func sessionDidRequestSample(for label: Class, requestID: UUID)

    /**
     * The session did add a contribution for a label (ig. the file was successfully saved).
     */

    func sessionDidAddContribution()

}

/**
 * A sample data gathering session.
 *
 * Set the `delegate`, and call `start` to start a new session.
 */

class Session {

    /// The delegate that receives informations about the session.
    weak var delegate: SessionDelegate?

    /// The number of contributions for each label.
    fileprivate(set) var contributions: [Class: Int]

    /// The desired size of ouput samples.
    let sampleSize = CGSize(width: 300, height: 300)

    private let storage: Storage
    private let labels: [Class] = Class.allLabels
    private var activeRequest: (UUID, Class)?

    // MARK: - Initialization

    init() throws {
        self.storage = try Storage()
        self.contributions = storage.fetchContributions()
    }

    // MARK: - Interacting with the session

    /**
     * Starts the session. Make sure `delegate` is set before calling this method.
     */

    func start() {

        guard labels.count >= 1 else {
            fatalError("No labels to classify.")
        }

        guard activeRequest == nil else {
            fatalError("Cannot start a request that is already active.")
        }

        requestSampleForNextLabel()

    }

    /**
     * Saves the provided sample for the given request. The sample data must be in the JPG format.
     */

    func completeRequest(withID requestID: UUID, sample: Data) throws {

        guard let activeRequest = self.activeRequest else {
            fatalError("Cannot complete a request that never started...")
        }

        guard activeRequest.0 == requestID else {
            fatalError("Wrong request. Only one request can be active at a time.")
        }

        guard storage.save(jpgImage: sample, for: activeRequest.1) == true else {
            throw NSError(domain: "SessionErrorDomain", code: 1000, userInfo: [
                NSLocalizedDescriptionKey: "The file could not be saved on disk."
            ])
        }

        let initialContriubutions = contributions[activeRequest.1] ?? 0
        contributions[activeRequest.1] = initialContriubutions + 1

        delegate?.sessionDidAddContribution()
        requestSampleForNextLabel()

    }

    private func requestSampleForNextLabel() {

        // Prioritize the labels with the lowest contributions
        let lowestContributors = labels.sorted {
            (self.contributions[$0]! < self.contributions[$1]!)
        }

        let requestID = UUID()
        let nextLabel = lowestContributors.first!

        self.activeRequest = (requestID, nextLabel)
        delegate?.sessionDidRequestSample(for: nextLabel, requestID: requestID)

    }

}
