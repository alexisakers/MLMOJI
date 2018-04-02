#!/bin/bash

#
#  MLMOJI
#
#  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
#
#  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
#

# Prepare directory
rm -rf augmented
cp -R training-data augmented

# Generate Data
python augmentor/main.py augmented/ fliph
python augmentor/main.py augmented/ noise_0.01
python augmentor/main.py augmented/ fliph,noise_0.01
python augmentor/main.py augmented/ fliph,rot_-30
python augmentor/main.py augmented/ fliph,rot_30
python augmentor/main.py augmented/ rot_15,trans_20_20
python augmentor/main.py augmented/ rot_33,trans_-20_50
python augmentor/main.py augmented/ trans_0_20,zoom_100_50_300_300
python augmentor/main.py augmented/ fliph,trans_50_20,zoom_60_50_200_200
python augmentor/main.py augmented/ rot_-15,zoom_75_50_300_300
python augmentor/main.py augmented/ rot_30
python augmentor/main.py augmented/ blur_4.0
python augmentor/main.py augmented/ fliph,blur_4.0
python augmentor/main.py augmented/ fliph,rot_30,blur_4.0
python augmentor/main.py augmented/ zoom_50_50_250_250
