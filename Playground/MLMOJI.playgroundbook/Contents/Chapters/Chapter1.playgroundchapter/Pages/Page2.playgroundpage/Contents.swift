//#-hidden-code
import UIKit
import PlaygroundSupport

var pendingFilters: [AugmentationFilter] = []
PlaygroundPage.current.needsIndefiniteExecution = true

/**
 * Rotates the image by the specified angle, in degrees.
 * - parameter degress: The angle to rotate the image by.
 */

func rotate(by degrees: CGFloat) {
    pendingFilters.append(.rotate(degrees))
}

/**
 * Moves the image on the screen.
 * - parameter x: The number of pixels to move the image by, horizontally. Can be negative.
 * - parameter y: The number of pixels to move the image by, vertically. Can be negative.
 */

func move(x: CGFloat, y: CGFloat) {
    pendingFilters.append(.translate(x, y))
}

/**
 * Zooms in or out of the image from the center, to the specified percentage.
 *
 * - parameter percentage: The percentage to scale the image to. Use a negative value to zoom
 * out. Use a positive value to zoom in.
 */

func zoom(percentage: CGFloat) {
    pendingFilters.append(.scale(percentage))
}

/**
 * Applies a light gaussian blur to the image.
 */

func blur() {
    pendingFilters.append(.blur)
}

//#-end-hidden-code
/*:
 # Building a Data Set

 ---

 The emoji recognizer you just tried is powered by a neural network, which was trained with a **data set** prior
 to being embedded into the playground.

 Neural networks need to be trained with real world images to learn the [features](glossary://feature) of each outcome
 before they can be used. So, for this task, we need to draw emoji for each class we will be predicting.

 However, the [classifier](glossary://classifier) needs hundreds, if not thousands of very different images
 for each class to reach satisfactory accuracy. As drawing is a very, *very* repetitive task, we need a
 process that generates the sketches for us.

 ## Meet Data Augmentation

 Some research are being conducted to explore generating synthetic images programmatically. For simplicity
 reasons, we will use a more approachable technique: **data augmentation**.

 Data augmentation allows us to generate new data from existing real images. With operations such as scaling,
 rotation, translation or blurring, we can create images that derive from an existing shape, but that include
 new features for the classifier to learn; because the augmented images look different.

 This is an example set of augmented images from a heart sketch:

 ![AugmentedSet.png](AugmentedSet.png)

 As you can see, 9 different drawings were generated from one sketch. The main benefit of this technique is
 its speed: it can increase the size of a medium-sized data set by ten times in less than 5 minutes.

 ## Augment your own drawing

 Now that we've learned about data augmentation, why not try it with our own drawing? To complete this challenge, you can follow these steps:

 1. Add a list of filters in the code editor below

 We will be using **cumulative augmentation**. Each filter is a function that will be applied on top of the previous one to produce the final image, in the order you write them.

 You can use these augmentation filters:

 - `rotate(by:)` using an angle in degrees.

 - `move(x:y:)` with numbers describing the movement of the image on the screen, in horizontal
 and vertical points.

 - `zoom(percentage:)` with a zoom percentage. A percentage lower than `100` makes the
 image smaller. A percentage greater than `100` makes the image bigger.

- `blur()` to blur the image with a light Gaussian blur.

 You drawing will be converted to a 250x250 pixel image, to which the filters will be applied. Keep
 these dimensions in mind when using the `move(x:y:)` filter, or your image may
 move off the screen.

 2. Run your code

 Feel free to experiment with different augmentation sequences by combining filters in multiple orders,
 using different arguments and repeating filters.

 */
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, rotate(by:))
//#-code-completion(identifier, show, move(x:y:))
//#-code-completion(identifier, show, zoom(percentage:))
//#-code-completion(identifier, show, blur())
//#-editable-code Tap to write your code
//#-end-editable-code

//#-hidden-code

if !pendingFilters.isEmpty {

    let vc = AugmentViewController(filters: pendingFilters)

    vc.completionHandler = {

        let pluralMark = pendingFilters.count > 1 ? "s" : ""

        PlaygroundPage.current.assessmentStatus = .pass(message: "You have created an augmented data set with \(pendingFilters.count) new image\(pluralMark)! You can move to [next page](@next), or keep experimenting with augmentation by editing your code.")

    }

    PlaygroundPage.current.liveView = PlaygroundViewController(child: vc)

} else {

    PlaygroundPage.current.assessmentStatus = .fail(hints: ["You did not add filters to augment your image."],
                                                    solution: "Add at least one filter between the brackets in the `augmentImage()` function.")

}

//#-end-hidden-code
