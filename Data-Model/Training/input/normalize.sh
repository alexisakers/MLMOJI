#!/bin/bash
set -e

#
#  MLMOJI
#
#  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
#
#  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
#

RAW_DIR=$(pwd)/augmented
NORMALIZED_DIR=$(pwd)/normalized
MOBILENET_IMAGE_SIZE=224

# Preparation
rm -rf $NORMALIZED_DIR
cp -R $RAW_DIR $NORMALIZED_DIR

# Rezsizing
cd $NORMALIZED_DIR
sips -Z $MOBILENET_IMAGE_SIZE heart/*.jpg
sips -Z $MOBILENET_IMAGE_SIZE cloud/*.jpg
sips -Z $MOBILENET_IMAGE_SIZE sun/*.jpg
sips -Z $MOBILENET_IMAGE_SIZE smile/*.jpg
sips -Z $MOBILENET_IMAGE_SIZE laugh/*.jpg
sips -Z $MOBILENET_IMAGE_SIZE croissant/*.jpg
sips -Z $MOBILENET_IMAGE_SIZE checkmark/*.jpg
