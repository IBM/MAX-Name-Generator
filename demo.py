from names import SmallConfig, train, namignize, namignator
import tensorflow as tf
import os
import sys

def main():
    try:
        while(True):
            response = input("Input a single name to be evaluated or leave input blank to generate a name.\n")
            if (response == ""):
                namignator(tf.train.latest_checkpoint("model"), SmallConfig)
            else:
                namignize([response.lower()], tf.train.latest_checkpoint("model"), SmallConfig)
    except (KeyboardInterrupt, EOFError):
        print("\nEnding demo.")

if __name__ == "__main__":
    main()
