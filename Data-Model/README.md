# Data Model

The Core ML model was built using transfer learning. To perform this task, I used

- A data set of hand-drawn emojis I created
- TensorFlow and Docker
- A pre-trained [MobileNet](https://arxiv.org/abs/1704.04861) snapshot
- Data augmentation

## Classes

The data model can recognize seven emojis:

- 😊 `smile`
- 😂 `laugh`
- ☀️ `sun`
- ☁️ `cloud`
- ❤️ `heart`
- ✔️ `checkmark`
- 🥐 `croissant`

## Training with your own data set

To build your own data set, you can use the `SampleCollection` iOS app. Once you want to train your model, export the saved samples using iTunes or Xcode and put them in the `Training/input/training-data` folder.

Open a shell in the `Training`  folder.

Run the `prepare.sh` script to download the dependencies and prepare the images. If you do not want to perform data augmentation (which requires high CPU resources), you can edit the `input/normalize` script to use the `input/training-data` folder instead of  `input/augmented`.

Once the `input/normalized` folder is filled with the normalized images, you can run the `retrain.sh` script to trai create the Core ML model. This can take around half an hour, depending on your computer's capabilities.

The  `EmojiSketches.coreml` model file in this directory will be updated when training has completed.
