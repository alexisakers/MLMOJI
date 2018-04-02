#!/bin/bash
set -e

#
#  MLMOJI
#
#  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
#
#  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
#

# Install dependencies
echo "👉  Installing dependencies..."
pip install -U tfcoreml six numpy scipy scikit-image opencv-python imgaug

# Normalize images
echo "👉  Normalizing images..."
cd input
sh ./normalize.sh

# Create output directory
echo "👉  Creating output directory..."
cd ..
rm -rf output && mkdir output

# Building TensorFlow image
echo "👉  Building Docker image"
docker build -t train-classifier .
