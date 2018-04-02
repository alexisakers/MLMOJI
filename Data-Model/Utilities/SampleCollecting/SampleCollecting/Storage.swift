//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import Foundation

/**
 * Manages the storage of the generated training data.
 */

class Storage {

    /// The URL of the output data set.
    let dataSetURL: URL

    init() throws {

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsDirectoryURL = URL(fileURLWithPath: documentsDirectory)

        self.dataSetURL = documentsDirectoryURL.appendingPathComponent("training-data")

        for label in Class.allLabels {

            let labelURL = dataSetURL.appendingPathComponent(label.rawValue)
            var isDirectory: ObjCBool = false

            if FileManager.default.fileExists(atPath: labelURL.path, isDirectory: &isDirectory) {

                if isDirectory.boolValue == false {
                    try FileManager.default.removeItem(at: labelURL)
                    try FileManager.default.createDirectory(at: labelURL, withIntermediateDirectories: true, attributes: nil)
                }

            } else {
                try FileManager.default.createDirectory(at: labelURL, withIntermediateDirectories: true, attributes: nil)
            }

        }

        // Clean up old images

        if let contents = try? FileManager.default.contentsOfDirectory(atPath: dataSetURL.path) {

            for item in contents {

                if Class(rawValue: item) == nil {
                    let url = dataSetURL.appendingPathComponent(item)
                    try FileManager.default.removeItem(at: url)
                }

            }

        }

    }

    /**
     * Saves the JPG image data for the specified label. Returns `true` if the operation was successful.
     */

    func save(jpgImage: Data, for label: Class) -> Bool {

        let itemURL = dataSetURL
            .appendingPathComponent(label.rawValue)
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        return FileManager.default.createFile(atPath: itemURL.path, contents: jpgImage, attributes: nil)

    }

    /**
     * The number of samples saved for every label.
     */

    func fetchContributions() -> [Class: Int] {

        var result: [Class: Int] = [:]

        for label in Class.allLabels {
            let labelURL = dataSetURL.appendingPathComponent(label.rawValue)
            let numberOfItems = (try? FileManager.default.contentsOfDirectory(atPath: labelURL.path))?.count ?? 0
            result[label] = numberOfItems
        }

        return result

    }

}
