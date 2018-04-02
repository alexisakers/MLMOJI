#!/bin/bash
set -e

#
#  MLMOJI
#
#  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
#
#  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
#

# Train classifier
echo "👉  Retraining model..."
docker run -it -v $(pwd)/output:/output \-v $(pwd)/input/normalized:/input train-classifier

# Export MLModel
echo "👉  Exporting model..."
python "export.py"
