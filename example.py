from names import SmallConfig, train, namignize, namignator
import tensorflow as tf
import os
import sys

data_dir = os.environ["DATA_DIR"]

train(data_dir + "/data/NationalNames.csv", "model/namignizer", SmallConfig)
