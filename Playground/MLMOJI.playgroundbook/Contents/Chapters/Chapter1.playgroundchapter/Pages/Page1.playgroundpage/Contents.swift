//#-hidden-code
import PlaygroundSupport

var startedPredictions = false
PlaygroundPage.current.needsIndefiniteExecution = true

/// Starts the predictive keyboard.
func startPredictions() {
    PlaygroundPage.current.proxy?.sendEvent(.startPredictions)
    startedPredictions = true
}
//#-end-hidden-code
/*:
 # MLMOJI : Hand-Drawn Emoji Recognition

 ---

 With more than 2000 emoji supported on iOS, it can be difficult to find the character you're after in the system keyboard. What if there were a keyboard that converts drawings to the corresponding emoji? ✨

 This is what this playground is all about! Using **Core Graphics** and **Core ML**, you'll be playing with a
 [deep neural network](glossary://dnn), and explore a more fun and intuitive way to type. 🤖

 The machine learning model was trained to recognize 7 hand-drawn objects:

 ![SupportedEmoji](SupportedEmoji.png)

 ## Getting started

 To launch the predictive keyboard, enter `startPredictions()` in the code editor below and run your code.

 Sketch your emoji in the white area on the right side of the screen. The keyboard
 will predict the most likely matches as you keep drawing. Here are some examples, for inspiration:

 ![EmojiStrokes](EmojiStrokes.png)

 After this, if you want to learn how the Core ML model was prepared, you can read the [next page](@next).

 */
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, startPredictions())
//#-editable-code Tap to write your code
//#-end-editable-code

//#-hidden-code
if !startedPredictions {
    PlaygroundPage.current.assessmentStatus = .fail(hints: ["You did not start the predictive keyboard."],
                                                    solution: "Enter `startPredictions()` in the code editor on the left and run your code again")
}
//#-end-hidden-code
