#
#  MLMOJI
#
#  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
#
#  Copyright (c) 2018 Alexis Aubry. Available under the terms of the MIT License.
#

import tfcoreml as tf_converter

tf_converter.convert(tf_model_path = 'output/tf_files/retrained_graph.pb',
                     mlmodel_path = '../EmojiSketches.mlmodel',
                     output_feature_names = ['final_result:0'],
                     class_labels = 'output/tf_files/retrained_labels.txt',
                     input_name_shape_dict = {'input:0' : [1, 224, 224, 3]},
                     image_input_names = ['input:0'])

